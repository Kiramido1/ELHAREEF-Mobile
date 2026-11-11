// Port of src/screens/PaymentFailedScreen.tsx.
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../services/bookings.dart';
import '../state/booking.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/icons.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

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
  bool _paying = false;

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _payCash() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      await confirmBookingCash();
      if (mounted) Nav.replace('Confirmed');
    } catch (_) {
      // RN leaves a rejection unhandled; only the spinner resets.
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final derived = context.watch<BookingController>().derive(i18n);

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
            child: Txt(t('payFailedSub'), size: 14, lineHeight: 22.5, color: c.ink6, center: true),
          ),
          const SizedBox(height: 20),
          EhCard(
            radius: Radii.box,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Txt('${derived.pitch.name} · ${derived.durStr}', size: 13.5, color: c.ink55)),
                Txt('${derived.total} ${t('egp')}', w: 800, size: 13.5),
              ],
            ),
          ),
          const Spacer(),
          Button(label: t('retryPay'), size: 15, onPressed: Nav.back),
          const SizedBox(height: 10),
          if (_paying)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.card,
                border: Border.all(color: c.ink14, width: 1.5),
                borderRadius: BorderRadius.circular(Radii.card14),
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: c.ink55, strokeWidth: 2.5),
              ),
            )
          else
            Button(
              label: t('payCashInstead'),
              variant: 'outline',
              size: 14,
              weight: 600,
              paddingV: 14,
              onPressed: _payCash,
            ),
        ],
      ),
    );
  }
}
