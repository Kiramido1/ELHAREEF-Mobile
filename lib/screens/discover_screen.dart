// Port of src/screens/DiscoverScreen.tsx.
import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../services/network.dart';
import '../state/matches.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../types.dart';
import '../widgets/anim.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  // RN Animated.timing default easing: easeInOut.
  late final _opacity = Tween<double>(
    begin: 0.25,
    end: 1,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(color: Brand.green, shape: BoxShape.circle),
    ),
  );
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.status, required this.onDetails, required this.onJoin});
  final Match match;
  final JoinStatus? status;
  final VoidCallback onDetails;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;
    final ar = i18n.lang == 'ar';
    final needed = match.total - match.joined;
    final full = needed == 0 && status != 'joined';
    final day = pick(match.day, dayAr[match.day] ?? match.day);
    final time = ar ? match.time.replaceFirst(' PM', ' م').replaceFirst(' AM', ' ص') : match.time;
    final dur = ar
        ? (match.durHours == 1 ? 'ساعة' : 'ساعتين')
        : '${match.durHours} hour${match.durHours == 1 ? '' : 's'}';
    final level = pick(match.level, levelAr[match.level] ?? match.level);
    final areaLabel = pick(match.area, areaAr[match.area] ?? match.area);
    final org = pick(match.org, match.orgAr);

    final joinLabel = full
        ? pick('FULL ${match.total}/${match.total}', 'كامل ${match.total}/${match.total}')
        : status == 'joined'
        ? t('openChat')
        : status == 'pending'
        ? t('requestSent')
        : ar
        ? 'انضم · محتاجين $needed'
        : 'Join match · $needed needed';
    final joinBg = full
        ? c.navyBtn
        : status == 'joined' || status == 'pending'
        ? c.tint
        : Brand.green;
    final joinFg = full
        ? Brand.white
        : status == 'joined'
        ? Brand.green
        : status == 'pending'
        ? c.ink55
        : Brand.white;

    return EhCard(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Press(
            onTap: onDetails,
            scale: 1,
            label: org,
            child: Row(
              children: [
                Avatar(initial: match.initial, palette: match.avatar, size: 44, fontSize: 15),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(org, w: 700, size: 15),
                      const SizedBox(height: 2),
                      Txt('${match.pitch} · $areaLabel', size: 12.5, color: c.ink55),
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.pill)),
                  child: Txt(level, w: 700, size: 11.5, color: c.ink6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text.rich(
                TextSpan(
                  style: Txt.style(context, size: 12.5, color: c.ink6),
                  children: [
                    TextSpan(text: day, style: Txt.style(context, w: 700, size: 12.5)),
                    TextSpan(text: ' · $time'),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Txt(dur, size: 12.5, color: c.ink6),
              const SizedBox(width: 14),
              const Spacer(),
              const SizedBox(width: 14),
              Txt('${match.joined}/${match.total} ${t('playersWord')}', w: 700, size: 12.5),
            ],
          ),
          const SizedBox(height: 9),
          ProgressBar(pct: match.joined / match.total * 100),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: Press(
                  onTap: onDetails,
                  scale: 0.97,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.card,
                      border: Border.all(color: c.ink14, width: 1.5),
                      borderRadius: BorderRadius.circular(Radii.action),
                    ),
                    child: Txt(t('details'), w: 600, size: 13),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 14,
                child: Press(
                  onTap: onJoin,
                  scale: status == 'pending' ? 1 : 0.97,
                  label: joinLabel,
                  child: Container(
                    // RN row stretches this borderless button to the bordered
                    // Details button's height (+3px), content top-aligned.
                    padding: const EdgeInsets.only(top: 11, bottom: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: joinBg, borderRadius: BorderRadius.circular(Radii.action)),
                    child: Txt(joinLabel, w: 700, size: 13, color: joinFg),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _chip = 0;
  final _scroll = ScrollController();
  static const _derivedPitchName = 'Dream Sports Arena';

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _handleJoin(Match match) {
    final m = context.read<MatchesController>();
    final status = m.joinStatus[match.id];
    if (status == 'joined') return Nav.navigate('Chat');
    if (status == 'pending') return;
    if (match.total - match.joined == 0) return Nav.navigate('MatchFull', match.id);
    m.join(match.id).catchError((Object e) {
      if (!mounted) return;
      if (e is MatchFullError) {
        Nav.navigate('MatchFull', match.id);
      } else if (e is NetworkError) {
        Nav.navigate('Offline');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final ar = i18n.lang == 'ar';
    final mc = context.watch<MatchesController>();
    final draft = mc.draft;

    final chips = ar
        ? ['كل الماتشات', 'النهارده', 'قريب مني', 'مستوايا']
        : ['All matches', 'Today', 'Near me', 'My level'];

    final needStr = ar
        ? draft.need == 1
              ? 'لاعيب واحد'
              : '${draft.need} لاعيبة'
        : '${draft.need} player${draft.need == 1 ? '' : 's'}';

    return Screen(
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
              child: Row(
                children: [
                  EhBackButton(onPressed: () => Nav.navigate('Home')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt(t('findTitle'), w: 800, size: 23, letterSpacing: -0.23),
                        const SizedBox(height: 5),
                        Txt(t('findSub'), size: 13.5, color: c.ink6),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (mc.posted)
              Container(
                margin: const EdgeInsets.only(top: 14, left: Layout.screenX, right: Layout.screenX),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                decoration: BoxDecoration(
                  color: c.limeTint,
                  border: Border.all(color: c.limeBd, width: 1.5),
                  borderRadius: BorderRadius.circular(Radii.box),
                ),
                child: Row(
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: Txt.style(context, size: 13, lineHeight: 18.5),
                          children: [
                            TextSpan(
                              text: t('matchLive'),
                              style: Txt.style(context, w: 700, size: 13, lineHeight: 18.5),
                            ),
                            TextSpan(text: ' $_derivedPitchName · ${t('needsWord')} $needStr.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Press(
                      onTap: () => Nav.navigate('MyMatches'),
                      scale: 0.95,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(color: c.navyBtn, borderRadius: BorderRadius.circular(Radii.chip9)),
                        child: Txt(t('manage'), w: 700, size: 12, color: Brand.white),
                      ),
                    ),
                  ],
                ),
              ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Layout.screenX, 14, Layout.screenX, 4),
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    EhChip(label: chips[i], selected: _chip == i, onPressed: () => setState(() => _chip = i)),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, m) in mc.matches.indexed) ...[
                    if (i > 0) const SizedBox(height: 13),
                    RevealOnScroll(
                      key: ValueKey(m.id),
                      controller: _scroll,
                      child: _MatchCard(
                        match: m,
                        status: mc.joinStatus[m.id],
                        onDetails: () {
                          context.read<MatchesController>().selectMatch(m.id);
                          Nav.navigate('MatchDetails', m.id);
                        },
                        onJoin: () => _handleJoin(m),
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
