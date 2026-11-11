// Port of src/screens/CreateMatchScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../i18n/i18n.dart';
import '../navigation/nav.dart';
import '../scope.dart';
import '../state/booking.dart';
import '../state/matches.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/anim.dart';
import '../widgets/input.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

const _levels = ['Beginner', 'Intermediate', 'Advanced', 'Any level'];

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final TextEditingController _desc =
      TextEditingController(text: context.read<MatchesController>().draft.description);

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  void _post() {
    context.read<MatchesController>().postMatch();
    Nav.navigate('Tabs', 'Discover');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final derived = context.watch<BookingController>().derive(i18n);
    final matches = context.watch<MatchesController>();
    final draft = matches.draft;

    final needStr = i18n.lang == 'ar'
        ? (draft.need == 1 ? 'لاعيب واحد' : '${draft.need} لاعيبة')
        : '${draft.need} player${draft.need == 1 ? '' : 's'}';

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Txt(text, w: 700, size: 13, color: c.ink65),
        );

    Widget needBox(int n, bool on) => Container(
          padding: on ? null : const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? Brand.green : c.card,
            borderRadius: BorderRadius.circular(Radii.input12),
            border: Border.all(color: on ? Brand.green : c.ink12, width: 1.5),
          ),
          child: Txt('$n', w: 800, size: 15, color: on ? Brand.white : null, center: true),
        );

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0, viewport.maxHeight - 40)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          EhBackButton(onPressed: Nav.back),
                          const SizedBox(width: 12),
                          Txt(t('createMatch'), w: 800, size: 18),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        decoration: BoxDecoration(
                          color: c.tint,
                          border: Border.all(color: c.ink08),
                          borderRadius: BorderRadius.circular(Radii.card14),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: Txt.style(context, size: 13, lineHeight: 19.5),
                            children: [
                              TextSpan(text: derived.pitch.name, style: Txt.style(context, w: 700, size: 13)),
                              TextSpan(text: ' · ${derived.dateStr} · ${derived.rangeStr}'),
                            ],
                          ),
                        ),
                      ),

                      label(t('playersNeeded')),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          for (final n in [1, 2, 3, 4, 5]) ...[
                            if (n > 1) const SizedBox(width: 8),
                            Expanded(
                              child: Press(
                                onTap: () => matches.setDraft(need: n),
                                scale: 1,
                                selected: draft.need == n,
                                child: SelectFade(
                                  on: draft.need == n,
                                  off: needBox(n, false),
                                  over: needBox(n, true),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      label(t('skill')),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final level in _levels)
                            EhChip(
                              label: i18n.pick(level, levelAr[level] ?? level),
                              selected: draft.level == level,
                              onPressed: () => matches.setDraft(level: level),
                              paddingV: 10,
                              paddingH: 16,
                              size: 13.5,
                            ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text.rich(
                          TextSpan(
                            style: Txt.style(context, w: 700, size: 13, color: c.ink65),
                            children: [
                              TextSpan(text: '${t('desc')} '),
                              TextSpan(text: t('optional'), style: Txt.style(context, w: 500, size: 13, color: c.ink4)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      // RN: fixed 76px multiline box (13px vertical padding),
                      // so three 50/3px lines fill it exactly.
                      Semantics(
                        label: t('desc'),
                        child: Input(
                          controller: _desc,
                          placeholder: t('descPh'),
                          onChanged: (v) => matches.setDraft(description: v),
                          maxLines: 3,
                          minLines: 3,
                          maxLength: 280,
                          keyboardType: TextInputType.multiline,
                          fontSize: 14,
                          style: const TextStyle(height: 50 / 3 / 14),
                          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        ),
                      ),

                      label(t('whoJoin')),
                      const SizedBox(height: 9),
                      Segmented(
                        options: [i18n.pick('Public', 'عام'), i18n.pick('Friends only', 'الأصحاب بس')],
                        selectedIndex: draft.privacy == 'public' ? 0 : 1,
                        onSelect: (i) => matches.setDraft(privacy: i == 0 ? 'public' : 'friends'),
                        paddingV: 11,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Button(label: '${t('postMatch')} $needStr', onPressed: _post),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
