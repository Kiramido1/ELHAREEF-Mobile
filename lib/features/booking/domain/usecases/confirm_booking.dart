import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/repositories/booking_repository.dart';

/// Re-checks availability for every session, then books and charges.
class ConfirmBooking {
  const ConfirmBooking(this._repo);
  final BookingRepository _repo;

  Future<Booking> call(BookingRequest request) async {
    for (final day in request.sessionDays) {
      final busy = await _repo.busyHours(request.pitchId, day);
      if (!BookingRules.canBook(request.startHour, request.hours, busy)) throw const SlotUnavailableError();
    }
    return _repo.confirm(request);
  }
}
