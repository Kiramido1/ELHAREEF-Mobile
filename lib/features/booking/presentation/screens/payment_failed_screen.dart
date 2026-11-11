// Port of src/screens/PaymentFailedScreen.tsx.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/booking_flow.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/icons.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

/// RN `Animated.spring({ friction: 5, tension: 90 })` converted with RN's
/// origami formulas: stiffness = (90 − 30)·3.62 + 194, damping = (5 − 8)·3 + 25.
const _popSpring = SpringDescription(mass: 1, stiffness: 411.2, damping: 16);

class PaymentFailedScreen extends StatefulWidget {
  const PaymentFailedScreen({super.key});

  @override
  State<PaymentFailedScreen> createState() => _PaymentFailedScreenState();
}

class _PaymentFailedScreenState extends State<PaymentFailedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController.unbounded(vsync: this)
    ..animateWith(SpringSimulation(_popSpring, 0, 1, 0));
  late final Timer _tick;
  PaymentMethod? _paying;

  @override
  void initState() {
    super.initState();
    // Repaint the hold countdown every second.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick.cancel();
    _pop.dispose();
    super.dispose();
  }

  Future<void> _pay(PaymentMethod? method) async {
    if (_paying != null) return;
    setState(() => _paying = method ?? PaymentMethod.card);
    try {
      await submitBooking(context, method: method);
    } finally {
      if (mounted) setState(() => _paying = null);
    }
  }

  void _pickAgain() {
    context.read<BookingController>().releaseHold();
    Nav.navigate('Booking');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final booking = context.watch<BookingController>();
    final left = booking.holdRemaining();
    final expired = left == null || left <= Duration.zero;
    final due = booking.quote.dueNow(booking.payMode);
    final spinner = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: c.ink55, strokeWidth: 2.5),
    );

    return Screen(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Center(
            child: AnimatedBuilder(
              animation: _pop,
              builder: (context, child) => Opacity(
                opacity: _pop.value.clamp(0.0, 1.0),
                child: Transform.scale(scale: 0.4 + 0.6 * _pop.value, child: child),
              ),
              child: Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(214, 69, 69, .12),
                ),
                child: const CrossIcon(size: 38, color: Brand.danger),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Txt(t('payFailed'), w: 800, size: 24, center: true),
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Txt(
              expired ? t('holdExpired') : '${t('payFailedHold')} ${i18n.fmt.countdown(left)} ${t('minutes')}.',
              size: 14,
              lineHeight: 22.5,
              color: c.ink6,
              center: true,
            ),
          ),
          const SizedBox(height: 20),
          EhCard(
            radius: Radii.box,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Txt('${booking.pitch.name} · ${i18n.fmt.hours(booking.hours)}', size: 13.5, color: c.ink55),
                ),
                Txt('$due ${t('egp')}', w: 800, size: 13.5),
              ],
            ),
          ),
          const Spacer(),
          if (expired)
            Button(label: t('pickAgain'), size: 15, onPressed: _pickAgain)
          else ...[
            if (_paying == PaymentMethod.card)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(Radii.card14)),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                ),
              )
            else
              Button(label: t('retryPay'), size: 15, onPressed: () => _pay(null)),
            const SizedBox(height: 10),
            if (_paying == PaymentMethod.cash)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.card,
                  border: Border.all(color: c.ink14, width: 1.5),
                  borderRadius: BorderRadius.circular(Radii.card14),
                ),
                child: spinner,
              )
            else
              Button(
                label: t('payCashInstead'),
                variant: 'outline',
                size: 14,
                weight: 600,
                paddingV: 14,
                onPressed: () => _pay(PaymentMethod.cash),
              ),
          ],
        ],
      ),
    );
  }
}
