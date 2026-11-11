// Port of src/screens/FindPlayersScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/profile/data/datasources/players_mock_datasource.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

/// 75% completion ring (design's conic-gradient 270°).
class _CompletionRing extends StatelessWidget {
  const _CompletionRing();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 52,
        child: CustomPaint(
          painter: _RingPainter(context.colors.tint),
          child: const Center(child: Txt('75%', w: 800, size: 11.5, center: true)),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.track);
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 22.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(rect.center, r, paint..color = track);
    // SVG rotated -90°: the dash starts at 12 o'clock and runs clockwise.
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * 0.75, false, paint..color = Brand.green);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.track != track;
}

class FindPlayersScreen extends StatelessWidget {
  const FindPlayersScreen({super.key, this.bookingId});
  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final bookings = context.watch<BookingsController>();
    final booking = bookings.byId(bookingId) ?? bookings.nextUpcoming;
    final fmt = i18n.fmt;
    final names = i18n.lang == 'ar' ? squadAr : squadEn;

    final squad = <({String label, String name, String palette})>[
      for (var i = 0; i < 8; i++)
        if (i < 6)
          (label: names[i][0], name: names[i], palette: i == 0 ? 'navy' : (i.isOdd ? 'tint' : 'green'))
        else
          (label: '?', name: i18n.lang == 'ar' ? 'ناقص' : 'Needed', palette: 'needed'),
    ];

    return Screen(
      child: LayoutBuilder(
        builder: (context, viewport) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: math.max(0, viewport.maxHeight - 40)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        EhBackButton(onPressed: Nav.back),
                        const SizedBox(width: 12),
                        Txt(i18n.t('needPlayersT'), w: 800, size: 18),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Txt(
                      booking == null
                          ? i18n.t('bookFirst')
                          : '${i18n.t('squadFor')} ${booking.pitchName} · ${fmt.dateLong(booking.start)} · ${fmt.hour(booking.startHour)}',
                      size: 14,
                      lineHeight: 21.5,
                      color: c.ink6,
                    ),
                    const SizedBox(height: 24),
                    _Grid(
                      columns: 4,
                      outset: 6,
                      children: [
                        for (final s in squad)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Avatar(initial: s.label, palette: s.palette, size: 62, fontSize: 17),
                                const SizedBox(height: 6),
                                Txt(s.name, w: 600, size: 11, color: c.ink55, center: true),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    EhCard(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Txt(i18n.t('sixOf8'), w: 800, size: 14.5),
                              const SizedBox(height: 3),
                              Txt(i18n.t('need2'), size: 12.5, color: c.ink55),
                            ],
                          ),
                          const _CompletionRing(),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Button(label: i18n.t('findPlayers'), onPressed: () => booking == null ? Nav.navigate('Search') : Nav.navigate('CreateMatch', booking.id)),
                      const SizedBox(height: 10),
                      Button(
                        label: i18n.t('skipFull'),
                        variant: 'ghost',
                        size: 14,
                        weight: 600,
                        paddingV: 12,
                        onPressed: () => Nav.navigate('Tabs', 'Home'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// RN `flexDirection: 'row', flexWrap: 'wrap'` grid with percentage-width
/// cells and a negative horizontal margin of [outset].
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.outset, required this.children});
  final int columns;
  final double outset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth + outset * 2;
          final cell = (width / columns * 1000).floorToDouble() / 1000;
          return OverflowBox(
            minWidth: width,
            maxWidth: width,
            fit: OverflowBoxFit.deferToChild,
            child: Wrap(
              // A plain RN 'row' (not the RTL-aware <Row>) keeps LTR order.
              textDirection: TextDirection.ltr,
              children: [for (final ch in children) SizedBox(width: cell, child: ch)],
            ),
          );
        },
      );
}
