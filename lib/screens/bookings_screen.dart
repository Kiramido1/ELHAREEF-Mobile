// Port of src/screens/BookingsScreen.tsx.
import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../services/bookings.dart';
import '../state/booking.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../types.dart';
import '../widgets/anim.dart';
import '../widgets/icons.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

const _tabs = ['confirmed', 'completed', 'cancelled'];

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tab = 0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Widget _smallButton({
    required String label,
    required VoidCallback onTap,
    required Color bg,
    Color? fg,
    Color? border,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
  }) => Press(
    onTap: onTap,
    scale: 0.95,
    child: Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        border: border == null ? null : Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Txt(label, w: 700, size: 12, color: fg),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;
    final derived = context.watch<BookingController>().derive(i18n);

    // The live booking from the current flow leads the Upcoming tab.
    final liveBooking = BookingRecord(
      id: 'EH-84213',
      pitch: derived.pitch.name,
      date: derived.dateStr,
      dateAr: derived.dateStr,
      time: derived.rangeStr,
      timeAr: derived.rangeStr,
      dur: derived.durStr,
      durAr: derived.durStr,
      status: 'confirmed',
      price: derived.total,
    );

    List<BookingRecord> byStatus(String status) => pastBookings.where((b) => b.status == status).toList();
    final list = _tab == 0 ? [liveBooking, ...byStatus('confirmed')] : byStatus(_tabs[_tab]);

    String statusLabel(String s) => s == 'confirmed'
        ? t('confirmedStatus')
        : s == 'completed'
        ? t('completedStatus')
        : t('cancelledStatus');
    (Color, Color) statusColors(String s) => s == 'confirmed'
        ? (c.tint, Brand.green)
        : s == 'completed'
        ? (c.chipGray, c.ink6)
        : (Brand.dangerBg, Brand.danger);

    Widget actions(BookingRecord b) {
      if (b.status == 'confirmed') {
        return Row(
          children: [
            _smallButton(
              label: t('findPlayers'),
              onTap: () => Nav.navigate('CreateMatch'),
              bg: c.card,
              border: c.ink14,
            ),
            const SizedBox(width: 8),
            // RN row stretches this borderless button to the bordered one's
            // height (+3px), content top-aligned.
            _smallButton(
              label: t('view'),
              onTap: () => Nav.navigate('BookingDetails'),
              bg: c.navyBtn,
              fg: Brand.white,
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 12),
            ),
          ],
        );
      }
      if (b.status == 'completed') {
        return _smallButton(label: t('bookAgain'), onTap: () => Nav.navigate('Booking'), bg: c.tint);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Txt(t('refunded'), w: 600, size: 12, color: c.ink5),
      );
    }

    return Screen(
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EhBackButton(onPressed: () => Nav.navigate('Home')),
                const SizedBox(width: 12),
                Flexible(child: Txt(t('bookTitle'), w: 800, size: 23, letterSpacing: -0.23)),
              ],
            ),
            const SizedBox(height: 14),
            Segmented(
              options: [t('upcoming'), t('completedTab'), t('cancelledTab')],
              selectedIndex: _tab,
              onSelect: (i) => setState(() => _tab = i),
            ),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 46, left: 24, right: 24),
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
                      child: const CalendarIcon(size: 30, color: Brand.green),
                    ),
                    const SizedBox(height: 14),
                    Txt(t('emptyBk'), w: 800, size: 16, center: true),
                    const SizedBox(height: 6),
                    Txt(t('emptyBkSub'), size: 13, lineHeight: 19.5, color: c.ink55, center: true),
                    const SizedBox(height: 16),
                    // RN <Button size={14} paddingV={13}> with paddingHorizontal 24
                    // and radius.input (core Button has no style override).
                    Press(
                      onTap: () => Nav.navigate('Booking'),
                      label: t('bookPitchBtn'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
                        decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(Radii.input)),
                        child: Txt(t('bookPitchBtn'), w: 700, size: 14, color: Brand.white, center: true),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, b) in list.indexed) ...[
                      if (i > 0) const SizedBox(height: 13),
                      RevealOnScroll(
                        key: ValueKey(b.id),
                        controller: _scroll,
                        child: Builder(
                          builder: (context) {
                            final (bg, fg) = statusColors(b.status);
                            return EhCard(
                              radius: Radii.card17,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: Txt(b.pitch, w: 700, size: 15)),
                                      StatusPill(label: statusLabel(b.status), bg: bg, fg: fg),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Txt(
                                    '${pick(b.date, b.dateAr)} · ${pick(b.time, b.timeAr)} · ${pick(b.dur, b.durAr)}',
                                    size: 12.5,
                                    color: c.ink55,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Txt('${b.price} ${t('egp')}', w: 800, size: 14), actions(b)],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
