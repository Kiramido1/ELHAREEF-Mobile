// Port of src/screens/PitchDetailsScreen.tsx.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart' show pitchPhotos;
import 'package:elhareef/features/pitches/presentation/controllers/pitches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/media.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class PitchDetailsScreen extends StatefulWidget {
  const PitchDetailsScreen({super.key, required this.pitchId});
  final int pitchId;

  @override
  State<PitchDetailsScreen> createState() => _PitchDetailsScreenState();
}

class _PitchDetailsScreenState extends State<PitchDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // RN useEffect → after the first frame (can't notify during build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookingController>().startFor(widget.pitchId);
    });
  }

  @override
  void didUpdateWidget(PitchDetailsScreen old) {
    super.didUpdateWidget(old);
    if (old.pitchId != widget.pitchId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<BookingController>().startFor(widget.pitchId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final insets = MediaQuery.paddingOf(context);
    final pitch = context.watch<PitchesController>().byId(widget.pitchId);
    final booking = context.watch<BookingController>();
    final slotsReady = booking.pitchId == pitch.id && !booking.loadingSlots;
    final slotsToday = booking.day == dayOf(booking.now);
    final ar = i18n.lang == 'ar';

    final areaLabel = i18n.pick(pitch.area, pitch.areaAr);
    final typeLabel = i18n.pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
    final distLabel = ar ? pitch.dist.replaceAll(' km', ' كم') : pitch.dist;
    final meta = ar
        ? '$areaLabel، الفيوم · $distLabel · ${pitch.reviews} تقييم'
        : '$areaLabel, Fayoum · $distLabel away · ${pitch.reviews} reviews';

    final facilities = [for (final f in pitch.facilities) ar ? f.ar : f.en];

    String fmtSlot(int h) => '${((h + 11) % 12) + 1} ${h % 24 >= 12 ? t('pm') : t('am')}';

    Widget tag(String label, {required int w, required Color bg, required Color fg}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.sm)),
          child: Txt(label, w: w, size: 12, color: fg),
        );

    final reviews = [
      (who: 'Karim S.', stars: '★★★★★', text: t('rev1')),
      (who: 'Omar T.', stars: '★★★★☆', text: t('rev2')),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, systemNavigationBarColor: c.bar),
      child: Screen(
        edgeToEdge: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero
                    PitchArt(
                      gradIndex: pitch.gradIndex,
                      photo: pitchPhotos[pitch.id],
                      height: 270,
                      children: [
                        Positioned(
                          top: insets.top + 6,
                          left: 18,
                          child: Press(
                            onTap: Nav.back,
                            label: 'Back',
                            child: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.card,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF030814).withValues(alpha: .25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Transform.translate(
                                offset: const Offset(0, -2),
                                child: const Txt('‹', size: 18, center: true),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(3, 8, 20, .75),
                              borderRadius: BorderRadius.circular(Radii.pill),
                            ),
                            child: Txt(t('photos'), w: 600, size: 11, color: Brand.cloud),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 18, left: Layout.screenX, right: Layout.screenX),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Txt(pitch.name, w: 800, size: 22, letterSpacing: -0.22)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                                decoration: BoxDecoration(
                                  color: c.tint,
                                  borderRadius: BorderRadius.circular(Radii.pill),
                                ),
                                child: Txt('★ ${pitch.rating}', w: 700, size: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Txt(meta, size: 13.5, color: c.ink6),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              tag(typeLabel, w: 700, bg: c.limeChip, fg: c.limeChipFg),
                              const SizedBox(width: 8),
                              tag(t('turf'), w: 600, bg: c.tint, fg: c.ink6),
                              const SizedBox(width: 8),
                              tag(t('floodlit'), w: 600, bg: c.tint, fg: c.ink6),
                            ],
                          ),

                          const SizedBox(height: 22),
                          Txt(t('facilitiesT'), w: 700, size: 15.5),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final f in facilities)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                                  decoration: BoxDecoration(
                                    color: c.card,
                                    border: Border.all(color: c.ink1, width: 1.5),
                                    borderRadius: BorderRadius.circular(Radii.pill),
                                  ),
                                  child: Txt(f, w: 500, size: 13),
                                ),
                            ],
                          ),

                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Txt(slotsToday ? t('tonightSlots') : t('tomorrow'), w: 700, size: 15.5),
                              Txt(i18n.fmt.dateLong(booking.day), size: 12, color: c.ink5),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final h in BookingRules.slotHours)
                                Builder(
                                  builder: (context) {
                                    final busy = !slotsReady || !booking.isStartAvailable(h);
                                    return Press(
                                      onTap: busy
                                          ? null
                                          : () {
                                              context.read<BookingController>().selectTime(h);
                                              Nav.navigate('Booking');
                                            },
                                      scale: 0.95,
                                      label: fmtSlot(h),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
                                        decoration: BoxDecoration(
                                          color: busy ? c.tint : c.card,
                                          border: Border.all(
                                            color: busy ? c.ink08 : const Color.fromRGBO(36, 165, 81, .4),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(Radii.md),
                                        ),
                                        child: Txt(
                                          fmtSlot(h),
                                          w: 600,
                                          size: 13,
                                          color: busy ? c.ink3 : Brand.green,
                                          decoration: busy ? TextDecoration.lineThrough : TextDecoration.none,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 22),
                          Txt(t('reviews'), w: 700, size: 15.5),
                          const SizedBox(height: 10),
                          for (var i = 0; i < reviews.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            EhCard(
                              radius: Radii.card14,
                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Txt(reviews[i].who, w: 700, size: 13),
                                      Txt(reviews[i].stars, w: 700, size: 13, color: Brand.green),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Txt(reviews[i].text, size: 13, lineHeight: 19.5, color: c.ink65),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky booking bar
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
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '${pitch.price} ',
                          style: Txt.style(context, w: 800, size: 19),
                          children: [
                            TextSpan(
                              text: t('egphr'),
                              style: Txt.style(context, w: 500, size: 12, color: c.ink5),
                            ),
                          ],
                        ),
                      ),
                      Txt(t('freeCancel'), w: 600, size: 11.5, color: Brand.green),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Button(label: t('bookThis'), onPressed: () => Nav.navigate('Booking')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
