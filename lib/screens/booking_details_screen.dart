// Port of src/screens/BookingDetailsScreen.tsx.
import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../services/bookings.dart';
import '../services/pitches.dart';
import '../state/booking.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/media.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor, this.wide = false});
  final String label, value;
  final Color? valueColor;
  final bool wide;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Txt(label, size: 13.5, color: context.colors.ink55)),
      Txt(value, w: 700, size: 13.5, color: valueColor, letterSpacing: wide ? 0.68 : null),
    ],
  );
}

/// RN `borderTopWidth: 1, borderStyle: 'dashed'`.
class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(height: 1, child: CustomPaint(painter: _DashPainter(color)));
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 3, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  /// RN `Alert.alert` with a cancel and a destructive action.
  void _confirmCancel(BuildContext context) {
    final i18n = context.read<I18n>();
    final c = context.read<ThemeController>().colors;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.card,
        title: Txt(i18n.t('cancelBk'), w: 700, size: 17),
        content: Txt(
          i18n.pick(
            'Cancel this booking? Free cancellation applies until Friday 8:00 AM.',
            'إلغاء الحجز ده؟ الإلغاء المجاني متاح حتى الجمعة 8 صباحًا.',
          ),
          size: 14,
          lineHeight: 20,
          color: c.ink75,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Txt(i18n.pick('Keep booking', 'خليه'), w: 600, size: 14, color: c.ink),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Nav.navigate('Tabs', 'Bookings');
            },
            child: Txt(i18n.t('cancelBk'), w: 600, size: 14, color: Brand.danger),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final booking = context.watch<BookingController>();
    final derived = booking.derive(i18n);

    final payLabel =
        (booking.payMethod == 'card' ? t('cardLabel') : t('walletLabel')) +
        (booking.payMode == 'deposit' ? t('depositPaid') : '');

    final rows = <Widget>[
      _DetailRow(label: t('bookingId'), value: bookingId, wide: true),
      _DetailRow(label: t('date'), value: derived.dateStr),
      _DetailRow(label: t('time'), value: derived.rangeStr),
      _DetailRow(label: t('duration'), value: derived.durStr),
      if (booking.recur) _DetailRow(label: t('schedule'), value: t('weekly4'), valueColor: Brand.green),
      _DetailRow(label: t('payment'), value: payLabel),
      _DashedLine(color: c.ink12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(t('total'), w: 800, size: 15),
          Txt('${derived.total} ${t('egp')}', w: 800, size: 15, color: Brand.green),
        ],
      ),
    ];

    return Screen(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      EhBackButton(onPressed: Nav.back),
                      const SizedBox(width: 12),
                      Flexible(child: Txt(t('bkDetails'), w: 800, size: 18)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  EhCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PitchArt(
                          gradIndex: derived.pitch.gradIndex,
                          photo: pitchPhotos[derived.pitch.id],
                          height: 110,
                          radius: const BorderRadius.vertical(top: Radius.circular(Radii.card - 1)),
                          children: [
                            const Positioned.fill(child: ColoredBox(color: Color.fromRGBO(3, 8, 20, .22))),
                            Positioned(
                              bottom: 11,
                              left: 15,
                              right: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  derived.pitch.name,
                                  style: Txt.style(context, w: 800, size: 16, color: Brand.cloud).copyWith(
                                    shadows: const [
                                      Shadow(color: Color.fromRGBO(3, 8, 20, .5), blurRadius: 6, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 11,
                              right: 11,
                              child: StatusPill(
                                label: t('confirmedChip'),
                                bg: Brand.lime,
                                fg: Brand.navy,
                                size: 10.5,
                                weight: 800,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 11), rows[i]],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      color: c.tint,
                      border: Border.all(color: c.ink08, width: 1),
                      borderRadius: BorderRadius.circular(Radii.card14),
                    ),
                    child: Txt(t('gateNote'), size: 12.5, lineHeight: 19.5, color: c.ink75),
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),
                  Button(
                    label: t('findForMatch'),
                    onPressed: () => Nav.navigate('CreateMatch'),
                    size: 15,
                    paddingV: 15,
                  ),
                  const SizedBox(height: 10),
                  Button(
                    label: t('cancelBk'),
                    variant: 'danger-outline',
                    size: 14,
                    weight: 600,
                    paddingV: 13,
                    onPressed: () => _confirmCancel(context),
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
