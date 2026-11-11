// Port of src/screens/BookingsScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/icons.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

const _tabs = [BookingStatus.confirmed, BookingStatus.completed, BookingStatus.cancelled];

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
    final fmt = i18n.fmt;
    final ctrl = context.watch<BookingsController>();
    final list = ctrl.withStatus(_tabs[_tab]);

    String statusLabel(BookingStatus s) => switch (s) {
          BookingStatus.confirmed => t('confirmedStatus'),
          BookingStatus.completed => t('completedStatus'),
          BookingStatus.cancelled => t('cancelledStatus'),
        };
    (Color, Color) statusColors(BookingStatus s) => switch (s) {
          BookingStatus.confirmed => (c.tint, Brand.green),
          BookingStatus.completed => (c.chipGray, c.ink6),
          BookingStatus.cancelled => (Brand.dangerBg, Brand.danger),
        };

    void bookAgain(Booking b) {
      context.read<BookingController>().startFor(b.pitchId);
      Nav.navigate('Booking');
    }

    Widget actions(Booking b, BookingStatus status) {
      if (status == BookingStatus.confirmed) {
        return Row(
          children: [
            _smallButton(
              label: t('findPlayers'),
              onTap: () => Nav.navigate('CreateMatch', b.id),
              bg: c.card,
              border: c.ink14,
            ),
            const SizedBox(width: 8),
            // RN row stretches this borderless button to the bordered one's
            // height (+3px), content top-aligned.
            _smallButton(
              label: t('view'),
              onTap: () => Nav.navigate('BookingDetails', b.id),
              bg: c.navyBtn,
              fg: Brand.white,
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 12),
            ),
          ],
        );
      }
      if (status == BookingStatus.completed) {
        return _smallButton(label: t('bookAgain'), onTap: () => bookAgain(b), bg: c.tint);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Txt(b.paidNow > 0 ? t('refunded') : t('cancelledStatus'), w: 600, size: 12, color: c.ink5),
      );
    }

    final emptyText = switch (_tabs[_tab]) {
      BookingStatus.confirmed => t('noUpcoming'),
      BookingStatus.completed => t('noCompleted'),
      BookingStatus.cancelled => t('noCancelled'),
    };

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
            if (list.isEmpty && !ctrl.loaded)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5))),
              )
            else if (list.isEmpty)
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
                    Txt(emptyText, w: 800, size: 16, center: true),
                    const SizedBox(height: 6),
                    Txt(t('emptyBkSub'), size: 13, lineHeight: 19.5, color: c.ink55, center: true),
                    const SizedBox(height: 16),
                    // RN <Button size={14} paddingV={13}> with paddingHorizontal 24
                    // and radius.input (core Button has no style override).
                    Press(
                      onTap: () => Nav.navigate('Search'),
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
                            final status = b.statusAt(ctrl.now);
                            final (bg, fg) = statusColors(status);
                            return Press(
                              onTap: () => Nav.navigate('BookingDetails', b.id),
                              scale: 0.99,
                              label: b.pitchName,
                              child: EhCard(
                              radius: Radii.card17,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: Txt(b.pitchName, w: 700, size: 15)),
                                      StatusPill(label: statusLabel(status), bg: bg, fg: fg),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Txt(
                                    '${fmt.dateLong(b.start)} · ${fmt.hourRange(b.startHour, b.hours)} · ${fmt.hours(b.hours)}',
                                    size: 12.5,
                                    color: c.ink55,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Txt('${b.total} ${t('egp')}', w: 800, size: 14), actions(b, status)],
                                  ),
                                ],
                              ),
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
