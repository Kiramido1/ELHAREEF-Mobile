// Port of src/screens/HomeScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/core/time/clock.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/features/booking/presentation/controllers/booking_controller.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/features/pitches/data/datasources/pitch_mock_datasource.dart' show pitchPhotos;
import 'package:elhareef/features/pitches/domain/entities/pitch.dart';
import 'package:elhareef/features/pitches/presentation/controllers/pitches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/icons.dart';
import 'package:elhareef/core/widgets/media.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

/// RN `Pressable` whose style depends on the pressed state.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.builder, required this.onTap, this.label});
  final Widget Function(bool pressed) builder;
  final VoidCallback onTap;
  final String? label;
  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
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
      child: widget.builder(_down),
    ),
  );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.i18n.t;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Skeleton(width: 42, height: 42, radius: 21),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 90, height: 11, radius: 6),
                    SizedBox(height: 7),
                    Skeleton(width: 130, height: 14, radius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              const Skeleton(width: 42, height: 42, radius: 21),
            ],
          ),
          const Skeleton(margin: EdgeInsets.only(top: 16), height: 50, radius: Radii.card14),
          const Skeleton(margin: EdgeInsets.only(top: 14), height: 150, radius: Radii.hero),
          const Skeleton(margin: EdgeInsets.only(top: 22), width: 140, height: 16, radius: 6),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            // The second card runs off-screen, as in the RN Row.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  Skeleton(width: 236, height: 210, radius: Radii.card),
                  SizedBox(width: 14),
                  Skeleton(width: 236, height: 210, radius: Radii.card),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SizedBox(
              width: double.infinity,
              child: Txt(t('finding'), w: 600, size: 12.5, color: c.ink45, center: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard({super.key, required this.pitch, required this.onPress});
  final Pitch pitch;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final typeLabel = i18n.pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
    final areaLabel = i18n.pick(pitch.area, areaAr[pitch.area] ?? pitch.area);
    final distLabel = i18n.lang == 'ar' ? pitch.dist.replaceFirst(' km', ' كم') : pitch.dist;
    return _Pressable(
      onTap: onPress,
      label: pitch.name,
      builder: (pressed) => Opacity(
        opacity: pressed ? 0.85 : 1,
        child: SizedBox(
          width: 236,
          child: EhCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PitchArt(
                  gradIndex: pitch.gradIndex,
                  photo: pitchPhotos[pitch.id],
                  height: 118,
                  // Card radius minus its 1px border (RN overflow: hidden).
                  radius: const BorderRadius.vertical(top: Radius.circular(Radii.card - 1)),
                  children: [
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(3, 8, 20, .75),
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Txt('★ ${pitch.rating}', w: 700, size: 11, color: Brand.cloud),
                      ),
                    ),
                    if (pitch.availableNow)
                      Positioned(
                        bottom: 9,
                        left: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                          decoration: BoxDecoration(color: Brand.lime, borderRadius: BorderRadius.circular(Radii.pill)),
                          child: Txt(i18n.t('availableNow'), w: 700, size: 10.5, color: Brand.navy),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(pitch.name, w: 700, size: 14.5),
                      const SizedBox(height: 4),
                      Txt('$areaLabel · $distLabel', size: 12, color: c.ink55),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: '${pitch.price}',
                              style: Txt.style(context, w: 700, size: 13.5, color: Brand.green),
                              children: [
                                TextSpan(
                                  text: i18n.t('perHrShort'),
                                  style: Txt.style(context, w: 500, size: 11.5, color: c.ink45),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.xs)),
                            child: Txt(typeLabel, w: 600, size: 11, color: c.ink5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMatchCard extends StatelessWidget {
  const _HomeMatchCard({required this.match, required this.onOpen});
  final Match match;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final needed = match.total - match.joined;
    final needsLabel = i18n.lang == 'ar' ? 'محتاج $needed لاعيبة' : 'Needs $needed player${needed == 1 ? '' : 's'}';
    final day = i18n.fmt.weekday(match.kickoff);
    final time = i18n.fmt.hour(match.kickoff.hour);
    return EhCard(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Avatar(initial: match.initial, palette: match.avatar, size: 40, fontSize: 14),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(needsLabel, w: 700, size: 14.5),
                    const SizedBox(height: 2),
                    Txt('${match.pitch} · $day $time', size: 12, color: c.ink55),
                  ],
                ),
              ),
              const SizedBox(width: 11),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.pill)),
                child: Txt('${match.joined}/${match.total}', w: 700, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(pct: match.joined / match.total * 100),
          const SizedBox(height: 12),
          Press(
            onTap: onOpen,
            scale: 0.97,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.navyBtn, borderRadius: BorderRadius.circular(Radii.action)),
              child: Txt(i18n.t('joinMatch'), w: 600, size: 13.5, color: Brand.white),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _HomeChip { nearMe, availableNow, today, tomorrow, popular, lowestPrice }

class _HomeScreenState extends State<HomeScreen> {
  List<Pitch>? _pitches;
  _HomeChip _chip = _HomeChip.nearMe;
  ({int? hour, DateTime day})? _hero;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _pitches = null);
    try {
      final list = await context.read<PitchesController>().load();
      if (!mounted) return;
      setState(() => _pitches = list);
      await _loadHero();
    } on NetworkError {
      if (mounted) Nav.navigate('Offline');
    }
  }

  /// Next free hour at the nearest pitch, tonight (or tomorrow when the
  /// Tomorrow chip is selected or tonight is fully booked).
  Future<void> _loadHero() async {
    final pitches = _pitches;
    if (pitches == null || pitches.isEmpty) return;
    final booking = context.read<BookingController>();
    final nearest = ([...pitches]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm))).first;
    final today = dayOf(booking.now);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    var day = _chip == _HomeChip.tomorrow ? tomorrow : today;
    var hour = await booking.firstFreeHour(nearest.id, day);
    if (hour == null && day == today && _chip != _HomeChip.today) {
      day = tomorrow;
      hour = await booking.firstFreeHour(nearest.id, day);
    }
    if (mounted) setState(() => _hero = (hour: hour, day: day));
  }

  void _selectChip(_HomeChip chip) {
    setState(() => _chip = chip);
    _loadHero();
  }

  /// The nearby list, ordered/filtered by the selected chip.
  List<Pitch> _visible(List<Pitch> all) {
    final list = [...all];
    switch (_chip) {
      case _HomeChip.availableNow:
        list.retainWhere((p) => p.availableNow);
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case _HomeChip.popular:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
      case _HomeChip.lowestPrice:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _HomeChip.nearMe || _HomeChip.today || _HomeChip.tomorrow:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  void _openHero(Pitch pitch) {
    final hero = _hero;
    context.read<BookingController>().startFor(pitch.id, onDay: hero?.day, atHour: hero?.hour);
    Nav.navigate('Booking');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final fmt = i18n.fmt;
    final dark = context.watch<ThemeController>().dark;
    final session = context.watch<SessionController>();
    final matchesCtrl = context.watch<MatchesController>();
    final matches = matchesCtrl.discover(MatchFilter.all);
    final now = matchesCtrl.now;
    final all = _pitches;

    final chipLabels = i18n.lang == 'ar'
        ? ['قريب مني', 'متاح دلوقتي', 'النهارده', 'بكرة', 'الأشهر', 'الأرخص']
        : ['Near me', 'Available now', 'Today', 'Tomorrow', 'Popular', 'Lowest price'];

    if (all == null) return const Screen(child: _HomeSkeleton());
    final pitches = _visible(all);
    final nearest = ([...all]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm))).first;
    final hero = _hero;
    final heroIsToday = hero == null || hero.day == dayOf(now);
    final heroKicker = '${t(heroIsToday ? 'heroTonight' : 'heroTomorrow')} ${nearest.name}'.toUpperCase();
    final heroSlot = hero == null
        ? '…'
        : hero.hour == null
        ? t('noFreeSlot')
        : '${fmt.hour(hero.hour!)} ${t('freeSlot')}';
    final distLabel = i18n.pick(nearest.dist, nearest.dist.replaceAll(' km', ' كم'));
    final heroSub = i18n.lang == 'ar'
        ? '$heroSlot · ${nearest.price} جنيه/ساعة · على بعد $distLabel'
        : '$heroSlot · ${nearest.price} EGP/hr · $distLabel away';

    return Screen(
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Semantics(
                        label: 'ELHAREEF',
                        image: true,
                        child: Image.asset(
                          dark ? 'assets/brand/symbol-reverse.png' : 'assets/brand/symbol.png',
                          width: 42,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Txt(t('playingIn'), w: 500, size: 11.5, color: c.ink5),
                          Txt(t('cairo'), w: 700, size: 15),
                        ],
                      ),
                    ],
                  ),
                  Press(
                    onTap: () => Nav.navigate('Profile'),
                    scale: 1,
                    label: t('nav4'),
                    child: Avatar(initial: session.session?.initial ?? 'Y', palette: 'navy', size: 42, fontSize: 15),
                  ),
                ],
              ),
            ),

            // Greeting
            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 16),
              child: Text.rich(
                TextSpan(
                  text: '${fmt.greeting(now, session.firstName)} ',
                  style: Txt.style(context, w: 800, size: 21, letterSpacing: -0.21),
                  children: [
                    TextSpan(
                      text: '— يلا نلعب؟',
                      style: Txt.style(context, ar: true, w: 600, size: 17, color: Brand.green),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 14),
              child: _Pressable(
                onTap: () => Nav.navigate('Search'),
                label: t('searchPh'),
                builder: (pressed) => Opacity(
                  opacity: pressed ? 0.8 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: c.card,
                      border: Border.all(color: c.ink1, width: 1.5),
                      borderRadius: BorderRadius.circular(Radii.card14),
                    ),
                    child: Row(
                      children: [
                        SearchIcon(size: 18, color: c.ink45),
                        const SizedBox(width: 10),
                        Flexible(child: Txt(t('searchPh'), size: 14.5, color: c.ink45)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Layout.screenX, 14, Layout.screenX, 4),
              child: Row(
                children: [
                  for (final chip in _HomeChip.values) ...[
                    if (chip.index > 0) const SizedBox(width: 8),
                    EhChip(label: chipLabels[chip.index], selected: _chip == chip, onPressed: () => _selectChip(chip)),
                  ],
                ],
              ),
            ),

            // Hero banner
            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 14),
              child: Press(
                onTap: () => _openHero(nearest),
                scale: 0.98,
                label: t('bookPitch'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.hero),
                  child: ColoredBox(
                    color: c.navyBtn,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -40,
                          child: IgnorePointer(
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color.fromRGBO(189, 249, 97, .22), width: 2),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IgnorePointer(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color.fromRGBO(36, 165, 81, .4), width: 2),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Txt(heroKicker, w: 700, size: 12, color: Brand.lime, letterSpacing: 0.96),
                              const SizedBox(height: 7),
                              Txt(t('bookPitch'), w: 800, size: 21, color: Brand.cloud, letterSpacing: -0.21),
                              const SizedBox(height: 5),
                              Txt(heroSub, size: 13.5, color: const Color.fromRGBO(251, 252, 250, .65)),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Brand.lime,
                                  borderRadius: BorderRadius.circular(Radii.pill),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: '${t('bookNow')} ',
                                    style: Txt.style(context, w: 700, size: 13.5, color: Brand.navy),
                                    children: [
                                      TextSpan(
                                        text: '›',
                                        style: Txt.style(context, size: 15, color: Brand.navy),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Nearby pitches
            const SizedBox(height: 26),
            SectionHeader(title: t('nearby'), actionLabel: t('seeAll'), onAction: () => Nav.navigate('Search')),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Layout.screenX, 12, Layout.screenX, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pitches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Txt(t('noPitchesChip'), size: 13, color: c.ink55),
                    ),
                  for (var i = 0; i < pitches.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    _PitchCard(
                      key: ValueKey(pitches[i].id),
                      pitch: pitches[i],
                      onPress: () => Nav.navigate('Pitch', pitches[i].id),
                    ),
                  ],
                ],
              ),
            ),

            // Looking for players
            const SizedBox(height: 24),
            SectionHeader(title: t('looking'), actionLabel: t('seeAll'), onAction: () => Nav.navigate('Discover')),
            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, m) in matches.take(2).indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    RevealOnScroll(
                      key: ValueKey(m.id),
                      controller: _scroll,
                      child: _HomeMatchCard(match: m, onOpen: () => Nav.navigate('MatchDetails', m.id)),
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
