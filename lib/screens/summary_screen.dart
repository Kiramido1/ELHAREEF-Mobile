// Port of src/screens/SummaryScreen.tsx.
import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../services/bookings.dart';
import '../services/network.dart';
import '../services/pitches.dart';
import '../state/booking.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/media.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueColor, this.bold = false});
  final String label, value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Txt(label, size: 13.5, color: context.colors.ink55)),
      Txt(value, w: bold ? 700 : 600, size: 13.5, color: valueColor),
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

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await confirmBooking(context.read<BookingController>().payMethod);
      if (!mounted) return;
      Nav.navigate('Confirmed');
    } on PaymentDeclinedError {
      if (mounted) Nav.navigate('PaymentFailed');
    } on NetworkError {
      if (mounted) Nav.navigate('Offline');
    } catch (_) {
      // Other errors are swallowed, as in the RN screen.
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final booking = context.watch<BookingController>();
    final derived = booking.derive(i18n);

    final typeLabel = i18n.pick(derived.pitch.type, typeAr[derived.pitch.type] ?? derived.pitch.type);
    final lineLabel = '${t('pitchWord')} · ${derived.durStr}${booking.recur ? t('x4weeks') : ''}';

    final rows = <Widget>[
      _SummaryRow(label: t('date'), value: derived.dateStr, bold: true),
      _SummaryRow(label: t('time'), value: derived.rangeStr, bold: true),
      _SummaryRow(label: t('duration'), value: derived.durStr, bold: true),
      _SummaryRow(label: t('pitchType'), value: typeLabel, bold: true),
      if (booking.recur) _SummaryRow(label: t('schedule'), value: t('weekly4'), valueColor: Brand.green, bold: true),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: _DashedLine(color: c.ink12),
      ),
      _SummaryRow(label: lineLabel, value: '${derived.price} ${t('egp')}'),
      _SummaryRow(label: t('fee'), value: '${derived.fee} ${t('egp')}'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(t('total'), w: 800, size: 16),
          Txt('${derived.total} ${t('egp')}', w: 800, size: 16, color: Brand.green),
        ],
      ),
      if (booking.payMode == 'deposit') ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Txt(t('dueNow'), size: 12.5, color: c.ink55),
            Txt('${derived.deposit} ${t('egp')}', w: 800, size: 12.5, color: Brand.green),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Txt(t('atVenue'), size: 12.5, color: c.ink55),
            Txt('${derived.remaining} ${t('egp')}', w: 600, size: 12.5),
          ],
        ),
      ],
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
                      Flexible(child: Txt(t('sumTitle'), w: 800, size: 18)),
                    ],
                  ),

                  const SizedBox(height: 18),
                  EhCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PitchArt(
                          gradIndex: derived.pitch.gradIndex,
                          photo: pitchPhotos[derived.pitch.id],
                          height: 86,
                          radius: const BorderRadius.vertical(top: Radius.circular(Radii.card - 1)),
                          children: [
                            const Positioned.fill(child: ColoredBox(color: Color.fromRGBO(3, 8, 20, .22))),
                            Positioned(
                              bottom: 10,
                              left: 14,
                              right: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  derived.pitch.name,
                                  style: Txt.style(context, w: 800, size: 15, color: Brand.cloud).copyWith(
                                    shadows: const [
                                      Shadow(color: Color.fromRGBO(3, 8, 20, .5), blurRadius: 6, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
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

                  const SizedBox(height: 18),
                  Txt(t('howMuch'), w: 700, size: 13, color: c.ink6),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('payFullLabel'),
                    sub: i18n.pick(
                      '${derived.total} EGP now · nothing at the venue',
                      '${derived.total} جنيه دلوقتي · مفيش حاجة في الملعب',
                    ),
                    selected: booking.payMode == 'full',
                    onPressed: () => context.read<BookingController>().setPayMode('full'),
                  ),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('payDepositLabel'),
                    sub: i18n.pick(
                      '${derived.deposit} EGP now · ${derived.remaining} EGP at the venue',
                      '${derived.deposit} جنيه دلوقتي · ${derived.remaining} جنيه في الملعب',
                    ),
                    selected: booking.payMode == 'deposit',
                    onPressed: () => context.read<BookingController>().setPayMode('deposit'),
                  ),

                  const SizedBox(height: 16),
                  Txt(t('payWith'), w: 700, size: 13, color: c.ink6),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('cardLabel'),
                    sub: t('cardSub'),
                    selected: booking.payMethod == 'card',
                    onPressed: () => context.read<BookingController>().setPayMethod('card'),
                  ),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('walletLabel'),
                    sub: t('walletSub'),
                    selected: booking.payMethod == 'wallet',
                    onPressed: () => context.read<BookingController>().setPayMethod('wallet'),
                  ),

                  const SizedBox(height: 14),
                  Txt(t('cancelNote'), size: 12, lineHeight: 18.5, color: c.ink5),

                  const Spacer(),
                  Press(
                    onTap: _submitting ? null : _confirm,
                    scale: 0.97,
                    label: '${t('confirmBk')} · ${derived.dueNow} ${t('egp')}',
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Brand.green,
                        borderRadius: BorderRadius.circular(Radii.card14),
                        boxShadow: Shadows.confirmCta,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Txt(
                              '${t('confirmBk')} · ${derived.dueNow} ${t('egp')}',
                              w: 700,
                              size: 16,
                              color: Colors.white,
                              center: true,
                            ),
                    ),
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
