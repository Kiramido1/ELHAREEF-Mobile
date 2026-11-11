import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/domain/repositories/booking_repository.dart';

/// Cancels a booking that has not kicked off yet.
class CancelBooking {
  const CancelBooking(this._repo, this._clock);
  final BookingRepository _repo;
  final Clock _clock;

  Future<Booking> call(Booking booking) async {
    if (!booking.canCancelAt(_clock.now())) throw const ValidationError('cancellation');
    return _repo.cancel(booking.id);
  }
}
