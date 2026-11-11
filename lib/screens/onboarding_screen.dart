// Port of src/screens/OnboardingScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/anim.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

typedef _Slide = ({List<String> title, List<String> body, List<String> cta});

const List<_Slide> _slides = [
  (
    title: ['Every pitch in the city, in your pocket', 'كل ملاعب المدينة في جيبك'],
    body: [
      'Real availability, real prices, real distances — from 5-a-side cages to full grounds.',
      'مواعيد حقيقية وأسعار حقيقية ومسافات حقيقية — من ملاعب الخماسي للملاعب الكبيرة.',
    ],
    cta: ['Next', 'التالي'],
  ),
  (
    title: ['Book in seconds, not phone calls', 'احجز في ثواني، من غير مكالمات'],
    body: [
      'Pick a date, a free slot, and how long you play. Done before the ad break ends.',
      'اختار اليوم والمعاد الفاضي ومدة اللعب. هتخلص قبل ما الإعلان يخلص.',
    ],
    cta: ['Next', 'التالي'],
  ),
  (
    title: ['Missing players? Not anymore.', 'ناقصك لاعيبة؟ مش تاني.'],
    body: [
      'Post your match and nearby hareefa fill the empty spots. Chat, coordinate, play.',
      'انشر ماتشك والحريف القريبين هيكملوا الأماكن الفاضية. اتكلموا ونسقوا والعبوا.',
    ],
    cta: ['Get started', 'يلا نبدأ'],
  ),
];

const _line = Color.fromRGBO(251, 252, 250, .35);
const _offWhite = Color(0xFFFDFEFC);

class _Slide0Art extends StatelessWidget {
  const _Slide0Art();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Positioned(
              top: 18,
              bottom: 18,
              left: 18,
              right: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: _line, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned(
              top: 18,
              bottom: 18,
              left: box.maxWidth / 2,
              width: 2,
              child: const ColoredBox(color: _line),
            ),
            Positioned(
              top: box.maxHeight / 2 - 46,
              left: box.maxWidth / 2 - 46,
              width: 92,
              height: 92,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color.fromRGBO(251, 252, 250, .4), width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 34,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                decoration: BoxDecoration(color: Brand.lime, borderRadius: BorderRadius.circular(Radii.pill)),
                child: const Txt('2.1 km away', w: 700, size: 12, color: Brand.navy),
              ),
            ),
            Positioned(
              top: 34,
              right: 34,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                decoration: BoxDecoration(color: _offWhite, borderRadius: BorderRadius.circular(Radii.pill)),
                child: const Txt('★ 4.8', w: 700, size: 12, color: Color(0xFF0B1533)),
              ),
            ),
          ],
        ),
      );
}

class _Slide1Art extends StatelessWidget {
  const _Slide1Art();

  @override
  Widget build(BuildContext context) {
    Widget plain(String label) => Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 22),
          decoration: BoxDecoration(color: _offWhite, borderRadius: BorderRadius.circular(12)),
          child: Txt(label, w: 600, size: 14, color: const Color(0xFF7F8A9E)),
        );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          plain('6:00 PM'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
            decoration: BoxDecoration(
              color: Brand.lime,
              borderRadius: BorderRadius.circular(12),
              boxShadow: Shadows.timeSelected,
            ),
            child: const Txt('8:00 PM ✓', w: 700, size: 15, color: Brand.navy),
          ),
          const SizedBox(height: 10),
          plain('10:00 PM'),
        ],
      ),
    );
  }
}

class _Slide2Art extends StatelessWidget {
  const _Slide2Art({required this.navyBtn, required this.ink4});
  final Color navyBtn, ink4;

  @override
  Widget build(BuildContext context) {
    Widget bubble(Color bg, Color fg, String label, {bool dashed = false}) {
      final inner = Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: dashed ? null : Border.all(color: Brand.green, width: 3),
        ),
        child: Txt(label, w: dashed ? 800 : 700, size: 15, color: fg, center: true),
      );
      return dashed ? CustomPaint(foregroundPainter: _DashedRing(ink4, 3), child: inner) : inner;
    }

    final bubbles = [
      bubble(_offWhite, const Color(0xFF0B1533), 'A'),
      bubble(navyBtn, Brand.cloud, 'O'),
      bubble(_offWhite, const Color(0xFF0B1533), 'K'),
      bubble(Brand.lime, Brand.navy, '+2', dashed: true),
    ];
    // RN: a plain 'row' with marginLeft -12 overlaps — physically LTR in both languages.
    return Center(
      child: SizedBox(
        width: 58 + 46.0 * (bubbles.length - 1),
        height: 58,
        child: Stack(
          textDirection: TextDirection.ltr,
          children: [
            for (var i = 0; i < bubbles.length; i++) Positioned(left: 46.0 * i, top: 0, child: bubbles[i]),
          ],
        ),
      ),
    );
  }
}

/// Dashed circular border (RN `borderStyle: 'dashed'` on a round view).
class _DashedRing extends CustomPainter {
  _DashedRing(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - width) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final n = (2 * math.pi * r / (width * 6)).floor();
    final sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(rect, i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.color != color || old.width != width;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _ob = 0;
  double _dir = 1;
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _go(int ob, double dir) {
    final changed = ob != _ob;
    setState(() {
      _dir = dir;
      _ob = ob;
    });
    if (changed) _anim.forward(from: 0);
  }

  void _next() {
    if (_ob < 2) {
      _go(_ob + 1, 1);
    } else {
      Nav.replace('Login');
    }
  }

  void _back() => _go(math.max(0, _ob - 1), -1);

  /// Slide-in: translateX from dir*30 → 0 with opacity 1 - |x|/30.
  Widget _animated(Widget child) => AnimatedBuilder(
        animation: _anim,
        child: child,
        builder: (context, child) {
          final x = _dir * 30 * (1 - easeOutExpo.transform(_anim.value));
          return Opacity(
            opacity: (1 - x.abs() / 30).clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(x, 0), child: child),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final li = i18n.lang == 'ar' ? 1 : 0;
    final slide = _slides[_ob];
    final grad = onboardingGradients[_ob];
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Screen(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ob > 0 ? EhBackButton(onPressed: _back) : const SizedBox(width: 38, height: 38),
              // hitSlop 8 → 8px padding, shifted back so the label sits at the edge.
              Transform.translate(
                offset: Offset(rtl ? -8 : 8, 0),
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Nav.replace('Login'),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Txt(i18n.t('skip'), w: 500, size: 14, color: c.ink5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _animated(
                  Container(
                    height: 300,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.onboarding),
                      gradient: LinearGradient(
                        colors: grad,
                        begin: Alignment.topLeft,
                        end: const Alignment(0.6, 1),
                      ),
                    ),
                    child: _ob == 0
                        ? const _Slide0Art()
                        : _ob == 1
                            ? const _Slide1Art()
                            : _Slide2Art(navyBtn: c.navyBtn, ink4: c.ink4),
                  ),
                ),
                const SizedBox(height: 30),
                _animated(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Txt(slide.title[li], w: 800, size: 27, lineHeight: 31, letterSpacing: -0.27),
                      const SizedBox(height: 10),
                      Txt(slide.body[li], size: 15, lineHeight: 24, color: c.ink6),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Container(
                      width: _ob == i ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _ob == i ? Brand.green : c.ink15,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ],
              ),
              Press(
                onTap: _next,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Brand.green,
                    borderRadius: BorderRadius.circular(Radii.card14),
                  ),
                  child: Txt(slide.cta[li], w: 600, size: 15, color: Brand.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
