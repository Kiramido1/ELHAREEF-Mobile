// Port of src/screens/SplashScreen.tsx.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation/nav.dart';
import '../theme/colors.dart';
import '../widgets/anim.dart';
import '../widgets/txt.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // mark: 0–1000ms; fade1: 900–1600ms; fade2: 1200–1900ms (one timeline).
  late final _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();
  late final _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  late final _loader = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  late final Animation<double> _mark = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 1000 / 1900, curve: easeOutExpo),
  );
  late final Animation<double> _fade1 = CurvedAnimation(
    parent: _intro,
    curve: const Interval(900 / 1900, 1600 / 1900, curve: Curves.easeInOut),
  );
  late final Animation<double> _fade2 = CurvedAnimation(
    parent: _intro,
    curve: const Interval(1200 / 1900, 1, curve: Curves.easeInOut),
  );
  late final Animation<double> _glowV = CurvedAnimation(parent: _glow, curve: Curves.easeInOut);
  late final Animation<double> _loaderV = CurvedAnimation(parent: _loader, curve: Curves.easeInOut);

  Timer? _timer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), _go);
  }

  void _go() {
    if (_left || !mounted) return;
    _left = true;
    Nav.replace('Onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _glow.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        child: ColoredBox(
          color: Brand.navy,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Absolute glow: horizontally centred, top-aligned with the logo (Yoga default).
                      Positioned(
                        top: 0,
                        child: AnimatedBuilder(
                          animation: _glowV,
                          builder: (context, child) => Opacity(
                            opacity: 0.35 + 0.35 * _glowV.value,
                            child: Transform.scale(scale: 1 + 0.18 * _glowV.value, child: child),
                          ),
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                radius: 0.5,
                                colors: [Brand.green.withValues(alpha: 0.32), Brand.green.withValues(alpha: 0)],
                                stops: const [0, 0.65],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _mark,
                        builder: (context, child) => Opacity(
                          opacity: _mark.value.clamp(0.0, 1.0),
                          child: Transform.scale(scale: 0.92 + 0.08 * _mark.value, child: child),
                        ),
                        child: Image.asset(
                          'assets/brand/splash-logo.png',
                          width: 222,
                          height: 135,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  FadeTransition(
                    opacity: _fade1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Txt('الحريف — ملعبك والعبها صح', ar: true, w: 600, size: 15, color: Brand.green),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 52,
                child: FadeTransition(
                  opacity: _fade2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          width: 132,
                          height: 4,
                          color: const Color.fromRGBO(251, 252, 250, .14),
                          alignment: Alignment.centerLeft,
                          // Kick Lime runner sweeping across the track.
                          child: AnimatedBuilder(
                            animation: _loaderV,
                            builder: (context, child) =>
                                Transform.translate(offset: Offset(-58 + 190 * _loaderV.value, 0), child: child),
                            child: Container(
                              width: 58,
                              height: 4,
                              decoration: BoxDecoration(color: Brand.lime, borderRadius: BorderRadius.circular(99)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          style: Txt.style(context, size: 13, color: Brand.cloud),
                          children: [
                            TextSpan(
                              text: 'ELHAREEF',
                              style: Txt.style(context, w: 700, size: 13, color: Brand.cloud),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: '— Book. Play. Win.',
                              style: Txt.style(context, size: 13, color: const Color.fromRGBO(251, 252, 250, .75)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
