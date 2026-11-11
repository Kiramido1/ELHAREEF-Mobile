// Business-logic parity checks against the RN implementation (expected
// values computed from the original TypeScript / JS Date semantics).
import 'package:elhareef/i18n/i18n.dart';
import 'package:elhareef/services/bookings.dart';
import 'package:elhareef/services/network.dart';
import 'package:elhareef/state/booking.dart';
import 'package:elhareef/state/chat.dart';
import 'package:elhareef/state/matches.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('booking defaults: price, fee, deposit, dates', () {
    final d = BookingController().derive(I18n());
    expect([d.price, d.fee, d.total, d.deposit, d.remaining, d.dueNow], [400, 20, 420, 105, 315, 420]);
    expect(d.dateStr, 'Friday, Aug 21'); // JS: new Date(2026, 7, 21).getDay() == 5
    expect(d.rangeStr, '8:00 PM – 10:00 PM');
    expect(d.timePicked, isFalse);
  });

  test('weekly recurrence: 4 sessions, deposit mode, month rollover, Arabic', () {
    final b = BookingController()
      ..selectDay(1, 28)
      ..selectDur(4)
      ..toggleRecur();
    final i18n = I18n();
    var d = b.derive(i18n);
    expect(b.payMode, 'deposit');
    expect([d.sessions, d.total, d.deposit, d.dueNow], [4, 3220, 805, 805]);
    expect(d.recurDates, ['Sep 28', 'Oct 5', 'Oct 12', 'Oct 19']);
    i18n.setLang('ar');
    d = b.derive(i18n);
    expect(d.durStr, '4 ساعات');
    expect(d.recurDates.first, '28 سبتمبر');
    b.toggleRecur();
    expect(b.payMode, 'full');
  });

  test('card payment declines first, then succeeds; wallet always succeeds', () async {
    await expectLater(confirmBooking('card'), throwsA(isA<PaymentDeclinedError>()));
    expect(await confirmBooking('card'), bookingId);
    expect(await confirmBooking('wallet'), bookingId);
  });

  test('join: pending → joined increments count; match 2 fills up', () async {
    final m = MatchesController();
    final f = m.join(0);
    expect(m.statusOf(0), 'pending');
    await f;
    expect(m.statusOf(0), 'joined');
    expect(m.byId(0).joined, 7);

    await expectLater(m.join(2), throwsA(isA<MatchFullError>()));
    expect(m.statusOf(2), 'none');
    expect(m.byId(2).joined, m.byId(2).total);
  });

  test('offline requests fail with NetworkError; chat ignores blank text', () async {
    final chat = ChatController();
    await chat.send('   ');
    expect(chat.messages.length, 5);
    setOffline(true);
    await expectLater(chat.send('hi'), throwsA(isA<NetworkError>()));
    setOffline(false);
    await chat.send(' hi ');
    expect(chat.messages.last.text, 'hi');
  });
}
