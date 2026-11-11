// Port of src/screens/MatchDetailsScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/widgets.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../services/network.dart';
import '../services/pitches.dart';
import '../services/players.dart';
import '../state/matches.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/media.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class MatchDetailsScreen extends StatelessWidget {
  const MatchDetailsScreen({super.key, required this.matchId});
  final int matchId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;
    final ar = i18n.lang == 'ar';
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final ctrl = context.watch<MatchesController>();
    final match = ctrl.matches.firstWhere((m) => m.id == matchId, orElse: () => ctrl.matches[0]);
    final status = ctrl.statusOf(match.id);
    final needed = match.total - match.joined;

    final day = pick(match.day, dayAr[match.day] ?? match.day);
    final time = ar ? match.time.replaceFirst(' PM', ' م').replaceFirst(' AM', ' ص') : match.time;
    final dur = ar
        ? (match.durHours == 1 ? 'ساعة' : 'ساعتين')
        : '${match.durHours} hour${match.durHours == 1 ? '' : 's'}';
    final level = pick(match.level, levelAr[match.level] ?? match.level);
    final org = pick(match.org, match.orgAr);
    final names = ar ? rosterAr : rosterEn;

    final slots = <({String label, String name, String palette})>[
      for (var i = 0; i < match.total; i++)
        if (i < match.joined)
          (label: names[i][0], name: names[i], palette: i.isOdd ? 'tint' : 'navy')
        else
          (label: '+', name: pick('Open', 'فاضي'), palette: 'open'),
    ];

    final joinLabel = status == 'joined'
        ? t('openSquadChat')
        : status == 'pending'
            ? (ar
                ? 'الطلب اتبعت — في انتظار ${match.orgAr.split(' ')[0]}'
                : 'Request sent — waiting for ${match.org.split(' ')[0]}')
            : t('requestToJoin');
    final joinBg = status == 'pending' ? c.tint : status == 'joined' ? c.navyBtn : Brand.green;
    final joinFg = status == 'pending' ? c.ink55 : Brand.white;

    Future<void> handleJoin() async {
      if (status == 'joined') return Nav.navigate('Chat');
      if (status == 'pending') return;
      if (needed == 0) return Nav.navigate('MatchFull', match.id);
      try {
        await context.read<MatchesController>().join(match.id);
      } on MatchFullError {
        Nav.navigate('MatchFull', match.id);
      } on NetworkError {
        Nav.navigate('Offline');
      }
    }

    Widget stat(String label, String value, [Color? color]) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(label, w: 600, size: 11.5, color: c.ink5),
            const SizedBox(height: 2),
            Txt(value, w: 800, size: 13, color: color),
          ],
        );

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
                Txt(t('matchDetails'), w: 800, size: 18),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(Layout.screenX, 16, Layout.screenX, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EhCard(
                    child: ClipRRect(
                      // overflow: 'hidden' clips to the inside of the 1px border.
                      borderRadius: BorderRadius.circular(Radii.card - 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PitchArt(
                            gradIndex: match.gradIndex,
                            photo: match.gradIndex < pitchPhotos.length ? pitchPhotos[match.gradIndex] : null,
                            height: 96,
                            children: [
                              const Positioned.fill(child: ColoredBox(color: Color.fromRGBO(3, 8, 20, .22))),
                              Positioned(
                                bottom: 10,
                                left: 14,
                                child: Text(
                                  match.pitch,
                                  style: Txt.style(context, w: 800, size: 16, color: Brand.cloud).copyWith(
                                    shadows: const [
                                      Shadow(color: Color.fromRGBO(3, 8, 20, .5), blurRadius: 6, offset: Offset(0, 1)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                stat(t('date'), day),
                                const SizedBox(width: 16),
                                stat(t('kickoff'), time),
                                const SizedBox(width: 16),
                                stat(t('duration'), dur),
                                const SizedBox(width: 16),
                                const Spacer(),
                                stat(t('level'), level, Brand.green),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  _OpacityPress(
                    label: org,
                    onTap: () => Nav.navigate('PlayerProfile', match.id),
                    child: EhCard(
                      radius: Radii.box,
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                      child: Row(
                        children: [
                          Avatar(initial: match.initial, palette: match.avatar, size: 42, fontSize: 14),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Txt(org, w: 700, size: 14.5),
                                Txt(t('orgMeta'), size: 12, color: c.ink55),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Txt('›', size: 17, color: c.ink35),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Txt('${t('playersT')} · ${match.joined}/${match.total}', w: 700, size: 15),
                      Txt('$needed ${t('spotsLeft')}', w: 700, size: 12.5, color: Brand.green),
                    ],
                  ),
                  const SizedBox(height: 11),
                  _Grid(
                    columns: 5,
                    outset: 5,
                    children: [
                      for (final s in slots)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            children: [
                              Avatar(initial: s.label, palette: s.palette, size: 50, fontSize: 14),
                              const SizedBox(height: 5),
                              Txt(s.name, w: 600, size: 10.5, color: c.ink55, center: true),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Txt(t('aboutMatch'), w: 700, size: 15),
                  const SizedBox(height: 7),
                  Txt(pick(match.desc, match.descAr), size: 13.5, lineHeight: 21.5, color: c.ink7),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                      color: c.tint,
                      border: Border.all(color: c.ink08),
                      borderRadius: BorderRadius.circular(Radii.input),
                    ),
                    child: Txt(t('matchTips'), size: 12.5, lineHeight: 19, color: c.ink75),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(Layout.screenX, 14, Layout.screenX, math.max(bottomInset, 14) + 12),
            decoration: BoxDecoration(
              color: c.bar,
              border: Border(top: BorderSide(color: c.ink08)),
            ),
            child: Semantics(
              enabled: status != 'pending',
              child: Press(
                onTap: handleJoin,
                scale: status == 'pending' ? 1 : 0.97,
                label: joinLabel,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: joinBg, borderRadius: BorderRadius.circular(Radii.card14)),
                  child: Txt(joinLabel, w: 700, size: 15.5, color: joinFg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// RN Pressable whose child dims to 0.85 opacity while pressed.
class _OpacityPress extends StatefulWidget {
  const _OpacityPress({required this.child, required this.onTap, required this.label});
  final Widget child;
  final VoidCallback onTap;
  final String label;

  @override
  State<_OpacityPress> createState() => _OpacityPressState();
}

class _OpacityPressState extends State<_OpacityPress> {
  bool _down = false;
  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _set(true),
          onTapUp: (_) => _set(false),
          onTapCancel: () => _set(false),
          child: Opacity(opacity: _down ? 0.85 : 1, child: widget.child),
        ),
      );
}

/// RN `flexDirection: 'row', flexWrap: 'wrap'` grid with percentage-width
/// cells and a negative horizontal margin of [outset].
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.outset, required this.children});
  final int columns;
  final double outset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth + outset * 2;
          final cell = (width / columns * 1000).floorToDouble() / 1000;
          return OverflowBox(
            minWidth: width,
            maxWidth: width,
            fit: OverflowBoxFit.deferToChild,
            child: Wrap(
              // A plain RN 'row' (not the RTL-aware <Row>) keeps LTR order.
              textDirection: TextDirection.ltr,
              children: [for (final ch in children) SizedBox(width: cell, child: ch)],
            ),
          );
        },
      );
}
