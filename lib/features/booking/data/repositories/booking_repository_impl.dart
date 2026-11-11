import 'dart:math';

import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/data/datasources/booking_local_datasource.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._local, {Random? random, this.declineFirstCardPayment = true})
      : _random = random ?? Random();

  final BookingLocalDatasource _local;
  final Random _random;

  /// Demo of the designed "payment failed" state: the first card charge of
  /// the session is declined, retries succeed.
  final bool declineFirstCardPayment;
  bool _declinedOnce = false;
  List<Booking>? _cache;

  List<Booking> get _bookings => _cache ??= _local.load();

  @override
  Future<List<Booking>> getBookings() async {
    await simulateRequest(null, 250);
    return [..._bookings]..sort((a, b) => b.start.compareTo(a.start));
  }

  @override
  Future<Set<int>> busyHours(int pitchId, DateTime day) async {
    final d = dayOf(day);
    final busy = {..._local.venueBusyHours(pitchId, d)};
    for (final b in _bookings) {
      if (b.pitchId != pitchId || b.status == BookingStatus.cancelled) continue;
      for (final s in b.sessionStarts) {
        if (dayOf(s) == d) {
          for (var h = s.hour; h < s.hour + b.hours; h++) {
            busy.add(h);
          }
        }
      }
    }
    return busy;
  }

  @override
  Future<Booking> confirm(BookingRequest r) async {
    if (r.method == PaymentMethod.card && declineFirstCardPayment && !_declinedOnce) {
      _declinedOnce = true;
      await simulateRequest(null, 900);
      throw const PaymentDeclinedError();
    }
    await simulateRequest(null, r.method == PaymentMethod.cash ? 500 : 800);
    final paidNow = r.method == PaymentMethod.cash ? 0 : r.quote.dueNow(r.payMode);
    final booking = Booking(
      id: _newId(),
      pitchId: r.pitchId,
      pitchName: r.pitchName,
      start: r.start,
      hours: r.hours,
      sessions: r.sessions,
      total: r.quote.total,
      paidNow: paidNow,
      method: r.method,
      payMode: r.payMode,
      status: BookingStatus.confirmed,
    );
    _cache = [..._bookings, booking];
    await _local.save(_bookings);
    return booking;
  }

  @override
  Future<Booking> cancel(String bookingId) async {
    await simulateRequest(null, 500);
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i < 0) throw const ValidationError('booking');
    final cancelled = _bookings[i].copyWith(status: BookingStatus.cancelled);
    _cache = [..._bookings]..[i] = cancelled;
    await _local.save(_bookings);
    return cancelled;
  }

  String _newId() {
    final taken = {for (final b in _bookings) b.id};
    String id;
    do {
      id = 'EH-${10000 + _random.nextInt(90000)}';
    } while (taken.contains(id));
    return id;
  }
}
