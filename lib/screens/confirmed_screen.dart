// Port of src/screens/ConfirmedScreen.tsx.
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

class ConfirmedScreen extends StatefulWidget {
  const ConfirmedScreen({super.key});

  @override
  State<ConfirmedScreen> createState() => _ConfirmedScreenState();
}

class _ConfirmedScreenState extends State<ConfirmedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController.unbounded(vsync: this)
    ..animateWith(SpringSimulation(_popSpring, 0, 1, 0));

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final derived = context.watch<BookingController>().derive(i18n);

    return Screen(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Brand.green,
                          boxShadow: Shadows.confirmPop,
                        ),
                        child: const CheckIcon(size: 44, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Txt(t('confirmedT'), w: 800, size: 25, letterSpacing: -0.25, center: true),
                  const SizedBox(height: 6),
                  const Directionality(
                    textDirection: TextDirection.rtl,
                    child: Txt('يلا، الملعب محجوز!', ar: true, size: 14, color: Brand.green, center: true),
                  ),

                  const SizedBox(height: 20),
                  EhCard(
                    padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Txt(derived.pitch.name, w: 800, size: 16.5),
                        const SizedBox(height: 5),
                        Txt('${derived.dateStr} · ${derived.rangeStr} · ${derived.durStr}', size: 13.5, color: c.ink6),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                          decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.action)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Txt(t('bookingId'), w: 600, size: 12, color: c.ink55),
                              const Txt(bookingId, w: 800, size: 14, letterSpacing: 0.84),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: c.limeTint,
                      border: Border.all(color: c.limeBd, width: 1.5),
                      borderRadius: BorderRadius.circular(Radii.box),
                    ),
                    child: Row(
                      children: [
                        const Avatar(initial: '6/8', palette: 'navy', size: 38, fontSize: 13),
                        const SizedBox(width: 12),
                        Expanded(child: Txt(t('missingP'), size: 13, lineHeight: 19.5)),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),
                  Button(label: t('findPlayers'), variant: 'navy', onPressed: () => Nav.navigate('FindPlayers')),
                  const SizedBox(height: 10),
                  Button(
                    label: t('viewBooking'),
                    variant: 'outline',
                    size: 14.5,
                    weight: 600,
                    paddingV: 14,
                    onPressed: () => Nav.navigate('BookingDetails'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
