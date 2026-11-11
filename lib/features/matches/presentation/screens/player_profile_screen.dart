// Port of src/screens/PlayerProfileScreen.tsx.
import 'package:flutter/widgets.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.valueColor});
  final String value, label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => EhCard(
        radius: Radii.card15,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Txt(value, w: 800, size: 20, color: valueColor, center: true),
            const SizedBox(height: 2),
            Txt(label, w: 600, size: 11.5, color: context.colors.ink55, center: true),
          ],
        ),
      );
}

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key, required this.matchId});
  final int matchId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final match = context.watch<MatchesController>().byId(matchId);
    final org = i18n.pick(match.org, match.orgAr);

    Widget pill(String label, {required Color bg, Color? fg, Border? border, double paddingV = 7}) => Container(
          padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: 13),
          decoration: BoxDecoration(color: bg, border: border, borderRadius: BorderRadius.circular(Radii.pill)),
          child: Txt(label, w: border == null ? 700 : 600, size: 12.5, color: fg),
        );

    return Screen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Layout.screenX, 0, Layout.screenX, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EhBackButton(onPressed: Nav.back),
                const SizedBox(width: 12),
                Txt(t('playerT'), w: 800, size: 18),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Avatar(initial: match.initial, palette: 'navy', size: 92, fontSize: 30, borderColor: Brand.green),
                const SizedBox(height: 12),
                Txt(org, w: 800, size: 21, center: true),
                const SizedBox(height: 3),
                Txt(t('playerMeta'), size: 13, color: c.ink55, center: true),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    pill(t('midfielder'), bg: c.tint),
                    const SizedBox(width: 8),
                    pill(t('intermediate'), bg: c.limeChip, fg: c.limeChipFg),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _StatCard(value: '42', label: t('matchesW'))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(value: '★ 4.8', label: t('rating'), valueColor: Brand.green)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(value: '12', label: t('hosted'))),
              ],
            ),

            const SizedBox(height: 20),
            Txt(t('about'), w: 700, size: 15),
            const SizedBox(height: 7),
            Txt(t('playerBio'), size: 13.5, lineHeight: 21.5, color: c.ink7),

            const SizedBox(height: 18),
            Txt(t('usually'), w: 700, size: 15),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in [t('weeknights'), t('fridays')])
                  pill(label, bg: c.card, border: Border.all(color: c.ink12, width: 1.5), paddingV: 8),
              ],
            ),

            const SizedBox(height: 18),
            Txt(t('reviews'), w: 700, size: 15),
            const SizedBox(height: 9),
            EhCard(
              radius: Radii.card14,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Txt('Karim S.', w: 700, size: 13),
                      Txt('★★★★★', w: 700, size: 13, color: Brand.green),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Txt(t('rev3'), size: 13, lineHeight: 19.5, color: c.ink65),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Button(label: t('message'), onPressed: () => Nav.navigate('Chat'), size: 15, paddingV: 15),
          ],
        ),
      ),
    );
  }
}
