// Port of src/screens/DiscoverScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

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
    final full = needed == 0 && status != JoinStatus.joined;
    final day = i18n.fmt.weekday(match.kickoff);
    final time = i18n.fmt.hour(match.kickoff.hour);
    final dur = i18n.fmt.hours(match.durHours);
    final level = pick(match.level, levelAr[match.level] ?? match.level);
    final areaLabel = pick(match.area, areaAr[match.area] ?? match.area);
    final org = pick(match.org, match.orgAr);

    final joinLabel = full
        ? pick('FULL ${match.total}/${match.total}', 'كامل ${match.total}/${match.total}')
        : status == JoinStatus.joined
        ? t('openChat')
        : status == JoinStatus.pending
        ? t('requestSent')
        : ar
        ? 'انضم · محتاجين $needed'
        : 'Join match · $needed needed';
    final joinBg = full
        ? c.navyBtn
        : status == JoinStatus.joined || status == JoinStatus.pending
        ? c.tint
        : Brand.green;
    final joinFg = full
        ? Brand.white
        : status == JoinStatus.joined
        ? Brand.green
        : status == JoinStatus.pending
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
                  scale: status == JoinStatus.pending ? 1 : 0.97,
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
  MatchFilter _filter = MatchFilter.all;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _handleJoin(Match match) {
    final m = context.read<MatchesController>();
    final status = m.statusOf(match.id);
    if (status == JoinStatus.joined) return Nav.navigate('Chat');
    if (status == JoinStatus.pending) return;
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
    final hosted = mc.hosted;
    final live = hosted.isEmpty ? null : hosted.last;
    final visible = mc.discover(_filter);

    final chips = ar
        ? ['كل الماتشات', 'النهارده', 'قريب مني', 'مستوايا']
        : ['All matches', 'Today', 'Near me', 'My level'];

    final need = live?.needed ?? 0;
    final needStr = ar
        ? need == 1
              ? 'لاعيب واحد'
              : '$need لاعيبة'
        : '$need player${need == 1 ? '' : 's'}';

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

            if (live != null)
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
                            TextSpan(text: ' ${live.pitch} · ${t('needsWord')} $needStr.'),
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
                    EhChip(
                      label: chips[i],
                      selected: _filter.index == i,
                      onPressed: () => setState(() => _filter = MatchFilter.values[i]),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
                      child: Txt(t('noMatchesFilter'), size: 13.5, color: c.ink55, center: true),
                    ),
                  for (final (i, m) in visible.indexed) ...[
                    if (i > 0) const SizedBox(height: 13),
                    RevealOnScroll(
                      key: ValueKey(m.id),
                      controller: _scroll,
                      child: _MatchCard(
                        match: m,
                        status: mc.statusOf(m.id),
                        onDetails: () => Nav.navigate('MatchDetails', m.id),
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
