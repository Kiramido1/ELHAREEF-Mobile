// Submits the booking and routes on the outcome. Shared by Summary and
// Payment failed so both paths behave identically.
import 'package:flutter/widgets.dart';

import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';

Future<void> submitBooking(BuildContext context, {PaymentMethod? method}) async {
  final booking = context.read<BookingController>();
  final bookings = context.read<BookingsController>();
  final t = context.read<I18n>().t;
  final outcome = await booking.confirm(overrideMethod: method);
  switch (outcome) {
    case ConfirmOutcome.confirmed:
      bookings.add(booking.lastBooking!);
      // Confirmed sits directly on top of the tabs: Back can't re-pay.
      Nav.resetToTabsThen('Confirmed', booking.lastBooking!.id);
    case ConfirmOutcome.declined:
      Nav.navigate('PaymentFailed');
    case ConfirmOutcome.slotTaken:
      showToast(t('slotTaken'), error: true);
      Nav.navigate('Booking');
    case ConfirmOutcome.offline:
      Nav.navigate('Offline');
    case ConfirmOutcome.failed:
      break;
  }
}
