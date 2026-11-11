import 'package:elhareef/features/booking/domain/entities/booking.dart';

abstract interface class BookingRepository {
  /// The user's bookings, newest kick-off first.
  Future<List<Booking>> getBookings();

  /// Start hours already taken on [day] at [pitchId].
  Future<Set<int>> busyHours(int pitchId, DateTime day);

  /// Charge and store the booking. Throws [PaymentDeclinedError] or
  /// [NetworkError].
  Future<Booking> confirm(BookingRequest request);

  /// Mark a booking cancelled.
  Future<Booking> cancel(String bookingId);
}
