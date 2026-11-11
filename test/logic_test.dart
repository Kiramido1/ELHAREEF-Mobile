// Domain rules, repositories and controllers — no widgets.
// Time is pinned with FixedClock and persistence uses MemoryStore, so every
// test is deterministic and isolated.
import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/i18n/formatters.dart';
import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:elhareef/features/auth/domain/entities/credentials.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:elhareef/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/usecases/confirm_booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/features/matches/data/datasources/match_local_datasource.dart';
import 'package:elhareef/features/matches/data/repositories/match_repository_impl.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart';
import 'package:elhareef/features/pitches/domain/entities/pitch_filter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wednesday 11 Nov 2026, 2 PM.
final now = DateTime(2026, 11, 11, 14);
final clock = FixedClock(now);

void main() {
  group('Quote', () {
    test('single session: hours × rate + fee, deposit floor 50', () {
      final q = Quote.of(pricePerHour: 100, hours: 1, sessions: 1, fee: 20);
      expect(q.price, 100);
      expect(q.total, 120);
      expect(q.deposit, 50);
      expect(q.dueNow(PayMode.deposit), 50);
      expect(q.dueNow(PayMode.full), 120);
    });

    test('weekly repeat multiplies sessions; deposit is 25% rounded to 5', () {
      final q = Quote.of(pricePerHour: 200, hours: 2, sessions: 4, fee: 20);
      expect(q.total, 1620);
      expect(q.deposit, 405);
      expect(q.remainingAfterDeposit, 1215);
    });
  });

  group('BookingRules', () {
    test('a booking cannot overlap a busy slot', () {
      expect(BookingRules.canBook(16, 2, {17}), isFalse);
      expect(BookingRules.canBook(18, 2, {17}), isTrue);
      expect(BookingRules.maxHoursFrom(16, {17}), 1);
    });

    test('a booking cannot run past closing time', () {
      expect(BookingRules.canBook(22, 2, {}), isTrue);
      expect(BookingRules.canBook(22, 4, {}), isFalse);
      expect(BookingRules.maxHoursFrom(22, {}), 2);
    });

    test('hours already started today are unavailable', () {
      final evening = DateTime(2026, 11, 11, 18, 30);
      expect(BookingRules.pastHours(dayOf(evening), evening), containsAll([16, 17, 18]));
      expect(BookingRules.pastHours(DateTime(2026, 11, 12), evening), isEmpty);
    });

    test('only today through the booking window is bookable', () {
      expect(BookingRules.isDayBookable(DateTime(2026, 11, 10), now), isFalse);
      expect(BookingRules.isDayBookable(DateTime(2026, 11, 11), now), isTrue);
      expect(BookingRules.isDayBookable(DateTime(2027, 2, 1), now), isFalse);
    });
  });

  group('PitchFilter', () {
    test('price and distance bands narrow the list', () {
      final mid = const PitchFilter(price: PriceBand.mid).apply(seedPitches);
      expect(mid, isNotEmpty);
      expect(mid.every((p) => p.price >= 150 && p.price < 220), isTrue);
      expect(const PitchFilter(price: PriceBand.under150).apply(seedPitches).every((p) => p.price < 150), isTrue);
      final bands = [PriceBand.under150, PriceBand.mid, PriceBand.over220];
      expect(bands.map((b) => PitchFilter(price: b).apply(seedPitches).length).reduce((a, b) => a + b), seedPitches.length);
      final near = const PitchFilter(distance: DistanceBand.under3).apply(seedPitches);
      expect(near.every((p) => p.distanceKm < 3), isTrue);
    });

    test('search matches name, area and facilities in either language', () {
      final first = seedPitches.first;
      expect(PitchFilter(query: first.name.toLowerCase()).apply(seedPitches), contains(first));
      final facility = first.facilities.first;
      expect(PitchFilter(query: facility.en).apply(seedPitches), contains(first));
      expect(PitchFilter(query: facility.ar).apply(seedPitches), contains(first));
      expect(const PitchFilter(query: 'zzzz-no-such-pitch').apply(seedPitches), isEmpty);
    });
  });

  group('EgyptianPhone', () {
    test('accepts national, trunk and international forms', () {
      expect(EgyptianPhone.normalize('1012345678'), '1012345678');
      expect(EgyptianPhone.normalize('01012345678'), '1012345678');
      expect(EgyptianPhone.normalize('+20 10 1234 5678'), '1012345678');
      expect(EgyptianPhone.display('1012345678'), '+20 10 1234 5678');
    });

    test('rejects letters, wrong prefixes and wrong lengths', () {
      expect(EgyptianPhone.isValid('abc'), isFalse);
      expect(EgyptianPhone.isValid('1312345678'), isFalse); // no 13 operator
      expect(EgyptianPhone.isValid('101234567'), isFalse);
      expect(EgyptianPhone.isValid('101234567890'), isFalse);
    });

    test('names need two letters', () {
      expect(CredentialRules.isValidName('Y'), isFalse);
      expect(CredentialRules.isValidName('Youssef Adel'), isTrue);
      expect(CredentialRules.isValidName('يوسف'), isTrue);
      expect(CredentialRules.isValidName('12'), isFalse);
    });
  });

  group('Formatters', () {
    const en = Formatters(arabic: false), ar = Formatters(arabic: true);
    test('plurals', () {
      expect(en.pitches(1), '1 pitch');
      expect(en.pitches(4), '4 pitches');
      expect(ar.hours(2), 'ساعتين');
      expect(en.hours(1), '1 hour');
    });
    test('hours, greeting, countdown', () {
      expect(en.hour(16), '4:00 PM');
      expect(en.hour(24), '12:00 AM');
      expect(en.greeting(DateTime(2026, 1, 1, 20), 'Mona'), 'Evening, Mona');
      expect(en.greeting(DateTime(2026, 1, 1, 9), 'Mona'), 'Morning, Mona');
      expect(en.countdown(const Duration(minutes: 9, seconds: 7)), '9:07');
      expect(en.countdown(const Duration(seconds: -3)), '0:00');
    });
  });

  group('Booking lifecycle', () {
    late BookingRepositoryImpl repo;
    setUp(() => repo = BookingRepositoryImpl(
          BookingLocalDatasource(MemoryStore(), clock),
          declineFirstCardPayment: false,
        ));

    BookingRequest request(DateTime day, int start, {int hours = 1}) => BookingRequest(
          pitchId: 0,
          pitchName: seedPitches.first.name,
          day: day,
          startHour: start,
          hours: hours,
          recurWeekly: false,
          quote: Quote.of(pricePerHour: 100, hours: hours, sessions: 1, fee: bookingFee),
          payMode: PayMode.full,
          method: PaymentMethod.card,
        );

    test('a fresh install has only past bookings', () async {
      final ctrl = BookingsController(repository: repo, clock: clock);
      await ctrl.refresh();
      expect(ctrl.withStatus(BookingStatus.confirmed), isEmpty);
      expect(ctrl.nextUpcoming, isNull);
    });

    test('confirm rejects a slot the venue already has', () async {
      final day = DateTime(2026, 11, 14);
      final busy = await repo.busyHours(0, day);
      await expectLater(
        ConfirmBooking(repo)(request(day, busy.first)),
        throwsA(isA<SlotUnavailableError>()),
      );
    });

    test('confirmed bookings get unique ids, persist, and can be cancelled', () async {
      final day = DateTime(2026, 11, 14);
      final busy = await repo.busyHours(0, day);
      final free = BookingRules.slotHours.where((h) => !busy.contains(h)).take(2).toList();
      final a = await ConfirmBooking(repo)(request(day, free[0]));
      final b = await ConfirmBooking(repo)(request(day, free[1]));
      expect(a.id, isNot(b.id));
      expect(a.id, startsWith('EH-'));

      // The booked hour is now busy for everyone else.
      expect(await repo.busyHours(0, day), contains(free[0]));

      final ctrl = BookingsController(repository: repo, clock: clock);
      await ctrl.refresh();
      expect(ctrl.nextUpcoming?.id, a.id);
      expect(a.canCancelAt(now), isTrue);
      expect(a.isFreeCancellationAt(now), isTrue);
      expect(a.freeCancellationUntil, a.start.subtract(BookingRules.freeCancellationWindow));

      await ctrl.cancel(a);
      expect(ctrl.byId(a.id)?.statusAt(now), BookingStatus.cancelled);
      expect(await repo.busyHours(0, day), isNot(contains(free[0])));
    });
  });

  group('Matches', () {
    late MatchesController ctrl;
    setUp(() async {
      ctrl = MatchesController(repository: MatchRepositoryImpl(MatchLocalDatasource(MemoryStore(), clock)), clock: clock);
      await ctrl.refresh();
    });

    test('join, then leave, updates capacity and the joined list', () async {
      final before = ctrl.byId(0).joined;
      await ctrl.join(0);
      expect(ctrl.statusOf(0), JoinStatus.joined);
      expect(ctrl.byId(0).joined, before + 1);
      expect(ctrl.joinedUpcoming.map((m) => m.id), contains(0));

      expect(await ctrl.leave(0), isTrue);
      expect(ctrl.statusOf(0), JoinStatus.none);
      expect(ctrl.byId(0).joined, before);
      expect(ctrl.joinedUpcoming.map((m) => m.id), isNot(contains(0)));
    });

    test('a match that fills up while joining reports MatchFullError', () async {
      await expectLater(ctrl.join(MatchLocalDatasource.fillsUpWhileJoiningId), throwsA(isA<MatchFullError>()));
      expect(ctrl.statusOf(MatchLocalDatasource.fillsUpWhileJoiningId), JoinStatus.none);
    });

    test('past matches are completed, not discoverable', () {
      expect(ctrl.completed.map((m) => m.id), contains(3));
      expect(ctrl.discover(MatchFilter.all).map((m) => m.id), isNot(contains(3)));
    });
  });

  group('Session', () {
    test('sign-in persists across restarts and sign-out clears it', () async {
      final store = MemoryStore();
      final session = SessionController(AuthRepositoryImpl(store));
      expect(session.signedIn, isFalse);
      expect(await session.signIn('010 1234 5678', 'secret1'), isTrue);
      expect(session.session?.phone, '1012345678');

      final restarted = SessionController(AuthRepositoryImpl(store));
      expect(restarted.signedIn, isTrue);
      await restarted.signOut();
      expect(SessionController(AuthRepositoryImpl(store)).signedIn, isFalse);
    });

    test('invalid credentials are rejected', () async {
      final session = SessionController(AuthRepositoryImpl(MemoryStore()));
      expect(await session.signIn('abc', 'secret1'), isFalse);
      expect(await session.signIn('1012345678', '123'), isFalse);
      expect(session.signedIn, isFalse);
    });

    test('onboarding is shown once; rename updates the session', () async {
      final store = MemoryStore();
      final session = SessionController(AuthRepositoryImpl(store));
      expect(session.onboardingSeen, isFalse);
      await session.completeOnboarding();
      expect(SessionController(AuthRepositoryImpl(store)).onboardingSeen, isTrue);

      await session.signUp('Mona Ali', '01112345678', 'secret1');
      expect(session.firstName, 'Mona');
      expect(await session.rename('Mona Hassan'), isTrue);
      expect(session.session?.name, 'Mona Hassan');
      expect(await session.rename('x'), isFalse);
    });
  });
}
