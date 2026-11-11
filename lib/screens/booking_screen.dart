// Port of src/screens/BookingScreen.tsx.
import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../state/booking.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/anim.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final insets = MediaQuery.paddingOf(context);
    final booking = context.watch<BookingController>();
    final derived = booking.derive(i18n);

    final monthDef = bookingMonths[booking.calMonth];
    final weekdays = i18n.lang == 'ar' ? weekdayShortAr : weekdayShortEn;
    // Week starts Saturday, matching the design's calendar offset.
    final calOffset = (DateTime(2026, monthDef.monthIndex + 1, 1).weekday % 7 + 1) % 7;

    final cells = <({int? day, bool past, bool selected})>[
      for (var i = 0; i < calOffset; i++) (day: null, past: false, selected: false),
      for (var d = 1; d <= monthDef.length; d++)
        (
          day: d,
          past: booking.calMonth == 0 && d < 21,
          selected: booking.selMonth == booking.calMonth && booking.selDay == d,
        ),
    ];

    String durLabel(int h) => i18n.lang == 'ar'
        ? h == 1
            ? 'ساعة'
            : h == 2
                ? 'ساعتين'
                : '$h ساعات'
        : '$h ${h == 1 ? 'hour' : 'hours'}';

    final areaLabel = i18n.pick(derived.pitch.area, areaAr[derived.pitch.area] ?? derived.pitch.area);
    final noTime = !derived.timePicked;

    Widget monthArrow(String glyph, bool active, VoidCallback onTap) => Press(
          onTap: onTap,
          scale: 1,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.ink12, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.chip9),
            ),
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: Txt(glyph, size: 15, color: active ? c.ink : c.ink25, center: true),
            ),
          ),
        );

    Widget calCell(({int? day, bool past, bool selected}) cell) => Press(
          onTap: cell.day == null || cell.past
              ? null
              : () => context.read<BookingController>().selectDay(booking.calMonth, cell.day!),
          scale: 1,
          selected: cell.selected,
          child: SelectFade(
            on: cell.selected,
            off: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              alignment: Alignment.center,
              child: Txt(
                cell.day?.toString() ?? '',
                w: 600,
                size: 13,
                color: cell.day == null
                    ? Colors.transparent
                    : cell.past
                        ? c.ink25
                        : c.ink,
                center: true,
              ),
            ),
            over: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(Radii.md)),
              child: Txt(cell.day?.toString() ?? '', w: 800, size: 13, color: Colors.white, center: true),
            ),
          ),
        );

    Widget timeCell(int h) {
      final busy = busyHours.contains(h);
      final on = booking.selTime == h;
      return Press(
        onTap: busy ? null : () => context.read<BookingController>().selectTime(h),
        scale: 1,
        selected: on,
        child: SelectFade(
          on: on,
          off: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: busy ? c.tint : c.card,
              border: Border.all(color: c.ink12, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.input12),
            ),
            child: Txt(
              derived.fmtHour(h),
              w: 600,
              size: 13.5,
              color: busy ? c.ink3 : c.ink,
              decoration: busy ? TextDecoration.lineThrough : TextDecoration.none,
              center: true,
            ),
          ),
          over: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Brand.green,
              border: Border.all(color: Brand.green, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.input12),
            ),
            child: Txt(derived.fmtHour(h), w: 600, size: 13.5, color: Colors.white, center: true),
          ),
        ),
      );
    }

    Widget durCell(int h) {
      final on = booking.selDur == h;
      return Press(
        onTap: () => context.read<BookingController>().selectDur(h),
        scale: 1,
        selected: on,
        child: SelectFade(
          on: on,
          off: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.ink12, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.input12),
            ),
            child: Txt(durLabel(h), w: 700, size: 13.5, center: true),
          ),
          over: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Brand.green,
              border: Border.all(color: Brand.green, width: 1.5),
              borderRadius: BorderRadius.circular(Radii.input12),
            ),
            child: Txt(durLabel(h), w: 700, size: 13.5, color: Colors.white, center: true),
          ),
        ),
      );
    }

    // The RN calendar and time grid are plain `flexDirection: 'row'` views
    // (not <Row>), so they keep left-to-right order in Arabic too.
    List<Widget> gridRows<T>(List<T> items, int perRow, Widget Function(T) cell, {double gap = 0, double runGap = 0}) {
      final rows = <Widget>[];
      for (var start = 0; start < items.length; start += perRow) {
        if (start > 0 && runGap > 0) rows.add(SizedBox(height: runGap));
        rows.add(Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var k = 0; k < perRow; k++) ...[
              if (k > 0 && gap > 0) SizedBox(width: gap),
              Expanded(child: start + k < items.length ? cell(items[start + k]) : const SizedBox()),
            ],
          ],
        ));
      }
      return rows;
    }

    return Screen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
            child: Row(
              children: [
                EhBackButton(onPressed: Nav.back),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(derived.pitch.name, w: 800, size: 16.5),
                      Txt('$areaLabel · ${derived.pitch.price} ${t('egphr')}', size: 12, color: c.ink55),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 6, left: Layout.screenX, right: Layout.screenX, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step 1 — date
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt(t('step1'), w: 700, size: 15),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          monthArrow('‹', booking.calMonth == 1, () => context.read<BookingController>().setCalMonth(0)),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 112),
                            child: Txt(i18n.pick(monthDef.nameEn, monthDef.nameAr), w: 700, size: 13, center: true),
                          ),
                          const SizedBox(width: 6),
                          monthArrow('›', booking.calMonth == 0, () => context.read<BookingController>().setCalMonth(1)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  EhCard(
                    radius: Radii.box,
                    padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          children: [
                            for (final w in weekdays)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Txt(w, w: 700, size: 10.5, color: c.ink4, center: true),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        ...gridRows(cells, 7, calCell),
                      ],
                    ),
                  ),

                  // Step 2 — time
                  const SizedBox(height: 20),
                  Txt(t('step2'), w: 700, size: 15),
                  const SizedBox(height: 14),
                  ...gridRows(slotHours, 3, timeCell, gap: 8, runGap: 8),
                  const SizedBox(height: 4),

                  // Step 3 — duration
                  const SizedBox(height: 20),
                  Txt(t('step3'), w: 700, size: 15),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var i = 0; i < durations.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: durCell(durations[i])),
                      ],
                    ],
                  ),

                  // Repeat weekly
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: booking.recur ? c.tint : c.card,
                      border: Border.all(
                        color: booking.recur ? const Color.fromRGBO(36, 165, 81, .45) : c.ink12,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(Radii.box),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Txt(t('repeatW'), w: 800, size: 14.5),
                                  const SizedBox(height: 3),
                                  Txt(t('repeatSub'), size: 12, color: c.ink55),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ToggleSwitch(
                              value: booking.recur,
                              onToggle: () => context.read<BookingController>().toggleRecur(),
                            ),
                          ],
                        ),
                        if (booking.recur) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              for (final d in derived.recurDates)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                                  decoration: BoxDecoration(
                                    color: c.card,
                                    border: Border.all(color: const Color.fromRGBO(36, 165, 81, .4), width: 1.5),
                                    borderRadius: BorderRadius.circular(Radii.pill),
                                  ),
                                  child: Txt(d, w: 700, size: 12, color: Brand.green),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Txt(t('repeatNote'), size: 12, lineHeight: 18, color: c.ink65),
                        ],
                      ],
                    ),
                  ),

                  // Selection summary
                  if (derived.timePicked) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
                      decoration: BoxDecoration(
                        color: c.tint,
                        border: Border.all(color: const Color.fromRGBO(36, 165, 81, .35), width: 1.5),
                        borderRadius: BorderRadius.circular(Radii.box),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Txt(derived.rangeStr, w: 800, size: 15.5),
                                const SizedBox(height: 3),
                                Txt('${derived.dateStr} · ${derived.durStr}', size: 12.5, color: c.ink6),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: '${derived.price} ',
                              style: Txt.style(context, w: 800, size: 18, color: Brand.green),
                              children: [
                                TextSpan(text: 'EGP', style: Txt.style(context, w: 600, size: 11, color: c.ink5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Sticky continue
          Container(
            decoration: BoxDecoration(
              color: c.bar,
              border: Border(top: BorderSide(color: c.ink08, width: 1)),
            ),
            padding: EdgeInsets.only(
              top: 14,
              left: Layout.screenX,
              right: Layout.screenX,
              bottom: (insets.bottom > 14 ? insets.bottom : 14) + 12,
            ),
            child: Press(
              onTap: noTime ? null : () => Nav.navigate('Summary'),
              scale: 0.97,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: noTime ? c.disabled : Brand.green,
                  borderRadius: BorderRadius.circular(Radii.card14),
                ),
                child: Txt(
                  noTime ? t('pickStartTime') : '${t('continue')} · ${derived.total} ${t('egp')}',
                  w: 700,
                  size: 15.5,
                  color: noTime ? c.ink35 : Colors.white,
                  center: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
