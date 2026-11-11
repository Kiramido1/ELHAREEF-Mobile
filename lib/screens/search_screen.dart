// Port of src/screens/SearchScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../services/pitches.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../types.dart';
import '../widgets/anim.dart';
import '../widgets/icons.dart';
import '../widgets/media.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

const _typeNames = ['All', '5-a-side', '7-a-side', '8-a-side', '11-a-side'];

class _ResultRow extends StatefulWidget {
  const _ResultRow({required this.pitch, required this.onPress});
  final Pitch pitch;
  final VoidCallback onPress;

  @override
  State<_ResultRow> createState() => _ResultRowState();
}

class _ResultRowState extends State<_ResultRow> {
  bool _pressed = false;
  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final pitch = widget.pitch;
    final typeLabel = i18n.pick(pitch.type, typeAr[pitch.type] ?? pitch.type);
    final areaLabel = i18n.pick(pitch.area, areaAr[pitch.area] ?? pitch.area);
    final distLabel = i18n.lang == 'ar' ? pitch.dist.replaceAll(' km', ' كم') : pitch.dist;
    return Semantics(
      button: true,
      label: pitch.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPress,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: Opacity(
          opacity: _pressed ? 0.85 : 1,
          child: EhCard(
            radius: Radii.card17,
            padding: const EdgeInsets.all(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PitchArt(
                  gradIndex: pitch.gradIndex,
                  photo: pitchPhotos[pitch.id],
                  width: 96,
                  height: 96,
                  radius: BorderRadius.circular(Radii.input12),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            // flexShrink name + space-between rating.
                            Expanded(
                              child: Txt(pitch.name, w: 700, size: 15, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Txt('★ ${pitch.rating}', w: 700, size: 12),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Txt('$areaLabel · $distLabel', size: 12.5, color: c.ink55),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.xs)),
                                child: Txt(typeLabel, w: 600, size: 11, color: c.ink55),
                              ),
                              if (pitch.availableNow) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: c.limeChip,
                                    borderRadius: BorderRadius.circular(Radii.xs),
                                  ),
                                  child: Txt(i18n.t('availableNow'), w: 700, size: 11, color: c.limeChipFg),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text.rich(
                            TextSpan(
                              style: Txt.style(context, w: 700, size: 14, color: Brand.green),
                              children: [
                                TextSpan(text: '${pitch.price} '),
                                TextSpan(
                                  text: i18n.t('egphr'),
                                  style: Txt.style(context, w: 500, size: 11.5, color: c.ink45),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onFindAnotherTime, required this.onClearFilters});
  final VoidCallback onFindAnotherTime;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.i18n.t;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const SearchIcon(size: 38, color: Brand.green),
                // RN `top: -2, right: -2` relative to the 96px circle.
                Positioned(
                  top: -2 - (96 - 38) / 2,
                  right: -2 - (96 - 38) / 2,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.navyBtn, shape: BoxShape.circle),
                    child: const Txt('0', w: 800, size: 13, color: Brand.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 18), child: Txt(t('noPitches'), w: 800, size: 18, center: true)),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Txt(t('noPitchesSub'), size: 13.5, lineHeight: 21, color: c.ink55, center: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            // Green Button with paddingHorizontal 26 / radius 13, shrink-wrapped.
            child: Press(
              onTap: onFindAnotherTime,
              label: t('anotherTime'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 26),
                decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(Radii.input)),
                child: Txt(t('anotherTime'), w: 700, size: 14.5, color: Brand.white, center: true),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Press(
              onTap: onClearFilters,
              scale: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Txt(t('clearFilters'), w: 600, size: 13.5, color: Brand.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.openFilters = false});
  final bool openFilters;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _q = TextEditingController();
  final _scroll = ScrollController();
  int _ftype = 0;
  int _fprice = 0;
  int _fdist = 0;
  late bool _sheet = widget.openFilters;

  // RN <Modal animationType="slide">: the whole modal slides up from below.
  late final _sheetAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    if (_sheet) _sheetAnim.forward();
  }

  @override
  void dispose() {
    _q.dispose();
    _scroll.dispose();
    _sheetAnim.dispose();
    super.dispose();
  }

  void _setSheet(bool v) {
    setState(() => _sheet = v);
    v ? _sheetAnim.forward() : _sheetAnim.reverse();
  }

  List<Pitch> get _results {
    final query = _q.text.toLowerCase();
    var list = allPitches.where((p) => query.isEmpty || '${p.name} ${p.area}'.toLowerCase().contains(query)).toList();
    if (_ftype > 0) list = list.where((p) => p.type == _typeNames[_ftype]).toList();
    return list;
  }

  void _clearFilters() {
    setState(() {
      _q.clear();
      _ftype = 0;
      _fprice = 0;
      _fdist = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;
    final results = _results;

    final typeChips = [for (final name in _typeNames) pick(name, typeAr[name] ?? name)];
    final priceChips = [pick('Under 150', 'أقل من 150'), '150–220', '+220'];
    final distChips = [
      pick('Under 3 km', 'أقل من 3 كم'),
      pick('Under 5 km', 'أقل من 5 كم'),
      pick('Anywhere', 'أي مكان'),
    ];

    final screen = Screen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
            child: Row(
              children: [
                EhBackButton(onPressed: Nav.back),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: c.card,
                      border: Border.all(color: Brand.green, width: 1.5),
                      borderRadius: BorderRadius.circular(Radii.input),
                    ),
                    child: Row(
                      children: [
                        SearchIcon(size: 17, color: c.ink45),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Semantics(
                            label: t('searchT'),
                            child: TextField(
                              controller: _q,
                              onChanged: (_) => setState(() {}),
                              autofocus: true,
                              cursorColor: Brand.green,
                              style: Txt.style(context, size: 14.5),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                hintText: pick('Pitch name, area, facility...', 'اسم الملعب، المنطقة، المرافق...'),
                                hintStyle: Txt.style(context, size: 14.5, color: c.ink45),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Press(
                  onTap: () => _setSheet(true),
                  label: t('filters'),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.navyBtn, borderRadius: BorderRadius.circular(Radii.input)),
                    child: const FilterIcon(size: 17, color: Brand.lime),
                  ),
                ),
              ],
            ),
          ),

          // Type chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 13, bottom: 4),
            child: Row(
              children: [
                for (var i = 0; i < typeChips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  EhChip(
                    key: ValueKey(typeChips[i]),
                    label: typeChips[i],
                    selected: _ftype == i,
                    onPressed: () => setState(() => _ftype = i),
                  ),
                ],
              ],
            ),
          ),

          if (results.isEmpty)
            Expanded(
              child: _NoResults(
                onFindAnotherTime: () => Nav.navigate('Booking'),
                onClearFilters: () {
                  _clearFilters();
                  _setSheet(true);
                },
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 10),
              child: Txt('${results.length} ${t('resultsMeta')}', size: 12.5, color: c.ink5),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, top: 12, bottom: 40),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 13),
                itemBuilder: (context, i) {
                  final item = results[i];
                  return RevealOnScroll(
                    key: ValueKey(item.id),
                    controller: _scroll,
                    child: _ResultRow(pitch: item, onPress: () => Nav.navigate('Pitch', item.id)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );

    return PopScope(
      canPop: !_sheet,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sheet) _setSheet(false); // Modal onRequestClose
      },
      child: Stack(
        children: [
          Positioned.fill(child: screen),
          // Filters bottom sheet
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sheetAnim,
              builder: (context, child) => _sheetAnim.isDismissed
                  ? const SizedBox.shrink()
                  : FractionalTranslation(
                      translation: Offset(0, 1 - Curves.easeOut.transform(_sheetAnim.value)),
                      child: IgnorePointer(ignoring: !_sheet, child: child),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: t('reset'),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _setSheet(false),
                        child: const ColoredBox(color: Color.fromRGBO(3, 8, 20, .55)),
                      ),
                    ),
                  ),
                  _sheetBody(context, results.length, typeChips, priceChips, distChips),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetBody(
    BuildContext context,
    int count,
    List<String> typeChips,
    List<String> priceChips,
    List<String> distChips,
  ) {
    final c = context.colors;
    final t = context.i18n.t;
    final isRTL = context.i18n.isRTL;
    Widget section(String text) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Txt(text, w: 700, size: 12.5, color: c.ink6),
    );
    Widget chips(List<String> labels, int selected, ValueChanged<int> onSelect) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < labels.length; i++)
            EhChip(
              key: ValueKey(labels[i]),
              label: labels[i],
              selected: selected == i,
              onPressed: () => onSelect(i),
              paddingV: 9,
            ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        top: 14,
        left: 22,
        right: 22,
        bottom: math.max(MediaQuery.paddingOf(context).bottom, 16) + 14,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: c.ink15, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Txt(t('filters'), w: 800, size: 18),
              // 8px horizontal hitSlop, offset back to the RN position.
              Transform.translate(
                offset: Offset(isRTL ? -8 : 8, 0),
                child: Press(
                  onTap: _clearFilters,
                  scale: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Txt(t('reset'), w: 600, size: 13, color: c.ink5),
                  ),
                ),
              ),
            ],
          ),
          section(t('pricePerHr')),
          chips(priceChips, _fprice, (i) => setState(() => _fprice = i)),
          section(t('pitchType')),
          chips(typeChips.sublist(1), _ftype - 1, (i) => setState(() => _ftype = i + 1)),
          section(t('distance')),
          chips(distChips, _fdist, (i) => setState(() => _fdist = i)),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Button(
              label: '${t('show')} $count ${t('pitchesWord')}',
              onPressed: () => _setSheet(false),
              size: 15,
              weight: 600,
              paddingV: 15,
            ),
          ),
        ],
      ),
    );
  }
}
