// Persists the user's bookings on-device and simulates the venue's
// schedule. A remote datasource would replace the schedule + payment parts.
import 'dart:convert';

import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/data/models/booking_model.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';

class BookingLocalDatasource {
  BookingLocalDatasource(this._store, this._clock);

  static const _key = 'bookings.v1';
  final KeyValueStore _store;
  final Clock _clock;

  List<Booking> load() {
    final raw = _store.getString(_key);
    if (raw == null) {
      final seeded = _seedHistory();
      save(seeded);
      return seeded;
    }
    try {
      return [for (final j in jsonDecode(raw) as List) BookingModel.fromJson((j as Map).cast<String, Object?>())];
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> save(List<Booking> bookings) =>
      _store.setString(_key, jsonEncode([for (final b in bookings) BookingModel.toJson(b)]));

  /// Other players' bookings at a venue: two deterministic busy hours per
  /// pitch per day, so the same day always shows the same schedule.
  Set<int> venueBusyHours(int pitchId, DateTime day) {
    var seed = (day.year * 372 + day.month * 31 + day.day) * 7 + pitchId * 13;
    final hours = <int>{};
    while (hours.length < 2) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      hours.add(BookingRules.slotHours[seed % BookingRules.slotHours.length]);
    }
    return hours;
  }

  /// Past bookings so a fresh install's history isn't empty.
  List<Booking> _seedHistory() {
    final today = dayOf(_clock.now());
    DateTime at(int daysAgo, int hour) => DateTime(today.year, today.month, today.day - daysAgo, hour);
    Booking past(String id, int pitchId, String name, DateTime start, int hours, int total, BookingStatus s) => Booking(
          id: id,
          pitchId: pitchId,
          pitchName: name,
          start: start,
          hours: hours,
          sessions: 1,
          total: total,
          paidNow: total,
          method: PaymentMethod.card,
          payMode: PayMode.full,
          status: s,
        );
    return [
      past('EH-82101', 2, 'Champions Park', at(5, 21), 2, 520, BookingStatus.completed),
      past('EH-81766', 3, 'Victory Grounds', at(19, 18), 1, 170, BookingStatus.completed),
      past('EH-80412', 1, 'Green Field Club', at(33, 20), 1, 200, BookingStatus.cancelled),
    ];
  }
}
