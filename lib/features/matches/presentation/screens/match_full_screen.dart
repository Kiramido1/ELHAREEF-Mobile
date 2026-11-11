// Port of src/screens/MatchFullScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class MatchFullScreen extends StatelessWidget {
  const MatchFullScreen({super.key, required this.matchId});
  final int matchId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final match = context.watch<MatchesController>().byId(matchId);

    // RN Alert.alert with a single OK button that goes back.
    void joinWaitlist() => showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(t('waitlist')),
            content: Text(i18n.pick(
              "You're on the waitlist. We'll notify you if a spot opens up.",
              'انت في قايمة الانتظار. هنبعتلك إشعار لو مكان فضي.',
            )),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Nav.back();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

    return Screen(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              EhBackButton(onPressed: Nav.back),
              const SizedBox(width: 12),
              Txt(t('matchDetails'), w: 800, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.75,
            child: EhCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Txt(match.pitch, w: 800, size: 15)),
                      StatusPill(label: t('fullChip'), bg: c.navyBtn, fg: Brand.white, size: 10.5, weight: 800),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Txt(t('mm5'), size: 12.5, color: c.ink55),
                  const SizedBox(height: 12),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(color: c.navyBtn, borderRadius: BorderRadius.circular(Radii.pill)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
                  child: Txt('${match.total}/${match.total}', w: 800, size: 26, center: true),
                ),
                const SizedBox(height: 16),
                Txt(t('fullT'), w: 800, size: 18, center: true),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Txt(t('fullSub'), size: 13.5, lineHeight: 21, color: c.ink55, center: true),
                ),
              ],
            ),
          ),
          Button(
            label: t('waitlist'),
            variant: 'outline',
            size: 14,
            weight: 600,
            paddingV: 14,
            onPressed: joinWaitlist,
          ),
          const SizedBox(height: 10),
          Button(label: t('anotherMatch'), size: 15, paddingV: 15, onPressed: Nav.back),
        ],
      ),
    );
  }
}
