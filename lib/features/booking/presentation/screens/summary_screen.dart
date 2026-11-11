// Port of src/screens/SummaryScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/booking_flow.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart' show pitchPhotos;
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/media.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

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

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final fmt = i18n.fmt;
    final insets = MediaQuery.paddingOf(context);
    final booking = context.watch<BookingController>();
    final pitch = booking.pitch;
    final quote = booking.quote;
    final start = booking.startHour;
    final deposit = booking.payMode == PayMode.deposit;
    final dueNow = quote.dueNow(booking.payMode);

    // Guard: the flow was reset (e.g. after confirming) — nothing to show.
    if (start == null) {
      return Screen(
        child: Center(
          child: Button(label: t('pickAgain'), onPressed: () => Nav.navigate('Booking')),
        ),
      );
    }

    final typeLabel = i18n.pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
    final durStr = fmt.hours(booking.hours);
    final lineLabel = '${t('pitchWord')} · $durStr${booking.recur ? t('x4weeks') : ''}';

    final rows = <Widget>[
      _SummaryRow(label: t('date'), value: fmt.dateLong(booking.day), bold: true),
      _SummaryRow(label: t('time'), value: fmt.hourRange(start, booking.hours), bold: true),
      _SummaryRow(label: t('duration'), value: durStr, bold: true),
      _SummaryRow(label: t('pitchType'), value: typeLabel, bold: true),
      if (booking.recur) _SummaryRow(label: t('schedule'), value: t('weekly4'), valueColor: Brand.green, bold: true),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: _DashedLine(color: c.ink12),
      ),
      _SummaryRow(label: lineLabel, value: '${quote.price} ${t('egp')}'),
      _SummaryRow(label: t('fee'), value: '${quote.fee} ${t('egp')}'),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(t('total'), w: 800, size: 16),
          Txt('${quote.total} ${t('egp')}', w: 800, size: 16, color: Brand.green),
        ],
      ),
      if (deposit) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Txt(t('dueNow'), size: 12.5, color: c.ink55),
            Txt('${quote.deposit} ${t('egp')}', w: 800, size: 12.5, color: Brand.green),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Txt(t('atVenue'), size: 12.5, color: c.ink55),
            Txt('${quote.remainingAfterDeposit} ${t('egp')}', w: 600, size: 12.5),
          ],
        ),
      ],
    ];

    final ctaLabel = '${t('confirmBk')} · $dueNow ${t('egp')}';

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
                Flexible(child: Txt(t('sumTitle'), w: 800, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  EhCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PitchArt(
                          gradIndex: pitch.gradIndex,
                          photo: pitchPhotos[pitch.id],
                          height: 86,
                          radius: const BorderRadius.vertical(top: Radius.circular(Radii.card - 1)),
                          children: [
                            const Positioned.fill(child: ColoredBox(color: Color.fromRGBO(3, 8, 20, .22))),
                            Positioned(
                              bottom: 10,
                              left: 14,
                              right: 0,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  pitch.name,
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
                      '${quote.total} EGP now · nothing at the venue',
                      '${quote.total} جنيه دلوقتي · مفيش حاجة في الملعب',
                    ),
                    selected: !deposit,
                    onPressed: () => context.read<BookingController>().setPayMode(PayMode.full),
                  ),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('payDepositLabel'),
                    sub: i18n.pick(
                      '${quote.deposit} EGP now · ${quote.remainingAfterDeposit} EGP at the venue',
                      '${quote.deposit} جنيه دلوقتي · ${quote.remainingAfterDeposit} جنيه في الملعب',
                    ),
                    selected: deposit,
                    onPressed: () => context.read<BookingController>().setPayMode(PayMode.deposit),
                  ),

                  const SizedBox(height: 16),
                  Txt(t('payWith'), w: 700, size: 13, color: c.ink6),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('cardLabel'),
                    sub: t('cardSub'),
                    selected: booking.payMethod == PaymentMethod.card,
                    onPressed: () => context.read<BookingController>().setPayMethod(PaymentMethod.card),
                  ),
                  const SizedBox(height: 9),
                  RadioOptionCard(
                    label: t('walletLabel'),
                    sub: t('walletSub'),
                    selected: booking.payMethod == PaymentMethod.wallet,
                    onPressed: () => context.read<BookingController>().setPayMethod(PaymentMethod.wallet),
                  ),

                  const SizedBox(height: 14),
                  Txt(t('cancelNote'), size: 12, lineHeight: 18.5, color: c.ink5),
                ],
              ),
            ),
          ),

          // Sticky confirm — always reachable without scrolling.
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
              onTap: booking.submitting ? null : () => submitBooking(context),
              scale: 0.97,
              label: ctaLabel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 17),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Brand.green,
                  borderRadius: BorderRadius.circular(Radii.card14),
                  boxShadow: booking.submitting ? const [] : Shadows.confirmCta,
                ),
                child: booking.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Txt(ctaLabel, w: 700, size: 16, color: Colors.white, center: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
