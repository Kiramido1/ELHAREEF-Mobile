// The user's bookings (Upcoming / Completed / Cancelled) and cancellation.
import 'package:flutter/foundation.dart';

import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/repositories/booking_repository.dart';
import 'package:elhareef/features/booking/domain/usecases/cancel_booking.dart';

class BookingsController extends ChangeNotifier {
  BookingsController({required BookingRepository repository, required Clock clock})
      : _repo = repository,
        _clock = clock,
        _cancel = CancelBooking(repository, clock);

  final BookingRepository _repo;
  final Clock _clock;
  final CancelBooking _cancel;

  List<Booking> _all = const [];
  bool loading = false;
  bool loaded = false;
  String? cancelling;

  DateTime get now => _clock.now();
  int get total => _all.length;

  List<Booking> withStatus(BookingStatus s) {
    final list = _all.where((b) => b.statusAt(now) == s).toList();
    // Upcoming: soonest first. History: most recent first.
    if (s == BookingStatus.confirmed) list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  Booking? byId(String? id) {
    for (final b in _all) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// The booking a "find players" / "create match" flow refers to.
  Booking? get nextUpcoming {
    final up = withStatus(BookingStatus.confirmed);
    return up.isEmpty ? null : up.first;
  }

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    try {
      _all = await _repo.getBookings();
      loaded = true;
    } on NetworkError {
      // Keep the last known list.
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Insert a just-confirmed booking without a round-trip.
  void add(Booking b) {
    _all = [b, ..._all.where((x) => x.id != b.id)];
    loaded = true;
    notifyListeners();
  }

  Future<bool> cancel(Booking b) async {
    if (cancelling != null) return false;
    cancelling = b.id;
    notifyListeners();
    try {
      final updated = await _cancel(b);
      _all = [for (final x in _all) x.id == updated.id ? updated : x];
      return true;
    } on AppFailure {
      return false;
    } finally {
      cancelling = null;
      notifyListeners();
    }
  }
}
