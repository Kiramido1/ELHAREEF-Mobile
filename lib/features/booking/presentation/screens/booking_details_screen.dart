// Port of src/screens/BookingDetailsScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart' show pitchPhotos, seedPitches;
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/media.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

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
  const BookingDetailsScreen({super.key, required this.bookingId});
  final String? bookingId;

  void _confirmCancel(BuildContext context, Booking booking) {
    final i18n = context.read<I18n>();
    final c = context.read<ThemeController>().colors;
    final ctrl = context.read<BookingsController>();
    final free = booking.isFreeCancellationAt(ctrl.now);
    final until = booking.freeCancellationUntil;
    final message = free
        ? '${i18n.t('cancelAsk')} ${i18n.t('freeCancelUntil')} ${i18n.fmt.dateLong(until)} · ${i18n.fmt.hour(until.hour)}.'
        : '${i18n.t('cancelAsk')} ${i18n.t('cancelClosed')}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.card,
        title: Txt(i18n.t('cancelBk'), w: 700, size: 17),
        content: Txt(message, size: 14, lineHeight: 20, color: c.ink75),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Txt(i18n.t('keepBooking'), w: 600, size: 14, color: c.ink),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final ok = await ctrl.cancel(booking);
              if (ok) {
                showToast(i18n.t('cancelledToast'));
              } else {
                showToast(i18n.t('cancelClosed'), error: true);
              }
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
    final fmt = i18n.fmt;
    final ctrl = context.watch<BookingsController>();
    final booking = ctrl.byId(bookingId);
    if (booking == null) {
      return Screen(child: Center(child: Button(label: t('myBookings'), onPressed: () => Nav.navigate('Bookings'))));
    }
    final status = booking.statusAt(ctrl.now);
    final pitch = seedPitches.firstWhere((p) => p.id == booking.pitchId, orElse: () => seedPitches.first);
    final cancelling = ctrl.cancelling == booking.id;

    final payLabel = switch (booking.method) {
          PaymentMethod.card => t('cardLabel'),
          PaymentMethod.wallet => t('walletLabel'),
          PaymentMethod.cash => t('cashLabel'),
        } +
        (booking.payMode == PayMode.deposit && booking.method != PaymentMethod.cash ? t('depositPaid') : '');

    final (pillLabel, pillBg, pillFg) = switch (status) {
      BookingStatus.confirmed => (t('confirmedChip'), Brand.lime, Brand.navy),
      BookingStatus.completed => (t('completedChip'), c.tint, c.ink55),
      BookingStatus.cancelled => (t('cancelledChip'), Brand.dangerBg, Brand.danger),
    };

    final rows = <Widget>[
      _DetailRow(label: t('bookingId'), value: booking.id, wide: true),
      _DetailRow(label: t('date'), value: fmt.dateLong(booking.start)),
      _DetailRow(label: t('time'), value: fmt.hourRange(booking.startHour, booking.hours)),
      _DetailRow(label: t('duration'), value: fmt.hours(booking.hours)),
      if (booking.sessions > 1) _DetailRow(label: t('schedule'), value: t('weekly4'), valueColor: Brand.green),
      _DetailRow(label: t('payment'), value: payLabel),
      _DashedLine(color: c.ink12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Txt(t('total'), w: 800, size: 15),
          Txt('${booking.total} ${t('egp')}', w: 800, size: 15, color: Brand.green),
        ],
      ),
      if (booking.dueAtVenue > 0 && status != BookingStatus.cancelled) ...[
        _DetailRow(label: t('paidNow'), value: '${booking.paidNow} ${t('egp')}'),
        _DetailRow(label: t('dueAtVenue'), value: '${booking.dueAtVenue} ${t('egp')}'),
      ],
    ];

    final until = booking.freeCancellationUntil;
    final note = status == BookingStatus.confirmed && booking.isFreeCancellationAt(ctrl.now)
        ? '${t('gateShow')} ${t('freeCancelUntil')} ${fmt.dateLong(until)} · ${fmt.hour(until.hour)}.'
        : t('gateShow');

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
                          gradIndex: pitch.gradIndex,
                          photo: pitchPhotos[pitch.id],
                          height: 110,
                          radius: const BorderRadius.vertical(top: Radius.circular(Radii.card - 1)),
                          children: [
                            const Positioned.fill(child: ColoredBox(color: Color.fromRGBO(3, 8, 20, .22))),
                            Positioned(
                              bottom: 11,
                              left: 15,
                              right: 0,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  booking.pitchName,
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
                                label: pillLabel,
                                bg: pillBg,
                                fg: pillFg,
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
                    child: Txt(note, size: 12.5, lineHeight: 19.5, color: c.ink75),
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),
                  if (status == BookingStatus.confirmed) ...[
                    Button(
                      label: t('findForMatch'),
                      onPressed: () => Nav.navigate('CreateMatch', booking.id),
                      size: 15,
                      paddingV: 15,
                    ),
                    const SizedBox(height: 10),
                    if (cancelling)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
                        ),
                      )
                    else if (booking.canCancelAt(ctrl.now))
                      Button(
                        label: t('cancelBk'),
                        variant: 'danger-outline',
                        size: 14,
                        weight: 600,
                        paddingV: 13,
                        onPressed: () => _confirmCancel(context, booking),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
