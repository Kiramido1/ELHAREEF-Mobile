// Port of src/screens/MyMatchesScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/features/matches/domain/entities/match.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});
  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  int _tab = 0;

  /// [kind]: 'navy' | 'outline' | 'danger'.
  Widget _actionButton(String label, VoidCallback onPress, String kind, {int flex = 10}) {
    final c = context.colors;
    final navy = kind == 'navy';
    return Expanded(
      flex: flex,
      child: Press(
        onTap: onPress,
        scale: 0.97,
        label: label,
        child: Container(
          // A borderless (navy) button is stretched by the RN row to its
          // bordered sibling's height (+3px), content top-aligned.
          padding: navy ? const EdgeInsets.only(top: 11, bottom: 14) : const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: navy ? c.navyBtn : c.card,
            border: navy
                ? null
                : Border.all(color: kind == 'danger' ? const Color.fromRGBO(214, 69, 69, .3) : c.ink14, width: 1.5),
            borderRadius: BorderRadius.circular(Radii.action),
          ),
          child: Txt(
            label,
            w: navy ? 700 : 600,
            size: 13,
            color: navy
                ? Brand.white
                : kind == 'danger'
                ? Brand.danger
                : c.ink,
          ),
        ),
      ),
    );
  }

  /// Two-button confirmation; resolves true when [confirmLabel] is tapped.
  Future<bool> _confirm(String title, String message, String cancelLabel, String confirmLabel) async {
    final c = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        title: Txt(title, w: 700, size: 17),
        content: Txt(message, size: 14, color: c.ink7),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Txt(cancelLabel, w: 600, size: 14, color: Brand.green),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Txt(confirmLabel, w: 600, size: 14, color: Brand.danger),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _info(String title, String message) {
    final c = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        title: Txt(title, w: 700, size: 17),
        content: Txt(message, size: 14, color: c.ink7),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Txt(MaterialLocalizations.of(ctx).okButtonLabel, w: 600, size: 14, color: Brand.green),
          ),
        ],
      ),
    );
  }

  Future<void> _leave(Match m) async {
    final i18n = context.read<I18n>();
    final ok = await _confirm(
      i18n.t('leave'),
      i18n.pick('Leave this match?', 'تنسحب من الماتش ده؟'),
      i18n.pick('Stay', 'خليك'),
      i18n.t('leave'),
    );
    if (!ok || !mounted) return;
    final left = await context.read<MatchesController>().leave(m.id);
    showToast(left ? i18n.t('leftToast') : i18n.t('postFailed'), error: !left);
  }

  Widget _cardHeader(String name, Widget pill) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Txt(name, w: 800, size: 15)),
      pill,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final pick = i18n.pick;
    const cardPad = EdgeInsets.symmetric(vertical: 16, horizontal: 17);
    const cardMargin = EdgeInsets.only(top: 16);
    final fmt = i18n.fmt;
    final ctrl = context.watch<MatchesController>();
    final list = switch (_tab) {
      0 => ctrl.hosted,
      1 => ctrl.joinedUpcoming,
      _ => ctrl.completed,
    };
    String when(Match m) => '${fmt.weekday(m.kickoff)} · ${fmt.hour(m.kickoff.hour)} · ${fmt.hours(m.durHours)}';

    return Screen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EhBackButton(onPressed: () => Nav.navigate('Home')),
                const SizedBox(width: 12),
                Flexible(child: Txt(t('matchTitle'), w: 800, size: 23, letterSpacing: -0.23)),
              ],
            ),
            const SizedBox(height: 14),
            Segmented(
              options: [t('hostingTab'), t('joinedTab'), t('completedTab')],
              selectedIndex: _tab,
              onSelect: (i) => setState(() => _tab = i),
            ),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 46, left: 12, right: 12),
                child: Column(
                  children: [
                    Txt(t(_tab == 0 ? 'noHosted' : _tab == 1 ? 'noJoined' : 'noCompletedMatches'), w: 700, size: 15, center: true),
                    const SizedBox(height: 16),
                    Button(
                      label: _tab == 0 ? t('bookAPitch') : t('findMatch'),
                      onPressed: () => _tab == 0 ? Nav.navigate('Search') : Nav.navigate('Discover'),
                    ),
                  ],
                ),
              ),
            for (final m in list)
              if (_tab == 0)
                EhCard(
                  lime: true,
                  margin: cardMargin,
                  padding: cardPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardHeader(
                        m.pitch,
                        StatusPill(label: t('hosting'), bg: c.limeChip, fg: c.limeChipFg, size: 10.5, weight: 800),
                      ),
                      const SizedBox(height: 5),
                      Txt(when(m), size: 12.5, color: c.ink55),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(child: ProgressBar(pct: m.joined / m.total * 100, height: 7)),
                          const SizedBox(width: 12),
                          Txt('${m.joined}/${m.total}', w: 800, size: 13),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Txt(
                        m.isFull
                            ? pick('Squad complete', 'الفريق كامل')
                            : pick(
                                '${m.needed} player${m.needed == 1 ? '' : 's'} needed',
                                m.needed == 1 ? 'محتاج لاعيب واحد' : 'محتاج ${m.needed} لاعيبة',
                              ),
                        w: 700,
                        size: 12.5,
                        color: Brand.green,
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          _actionButton(t('squadChat'), () => Nav.navigate('Chat'), 'outline'),
                          const SizedBox(width: 9),
                          _actionButton(t('openMatch'), () => Nav.navigate('MatchDetails', m.id), 'navy', flex: 14),
                        ],
                      ),
                    ],
                  ),
                )
              else if (_tab == 1)
                EhCard(
                  margin: cardMargin,
                  padding: cardPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardHeader(
                        m.pitch,
                        StatusPill(label: t('joinedChip'), bg: c.tint, fg: Brand.green, size: 10.5, weight: 800),
                      ),
                      const SizedBox(height: 5),
                      Txt('${when(m)} · ${pick('organized by', 'تنظيم')} ${pick(m.org, m.orgAr).split(' ').first}', size: 12.5, color: c.ink55),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          _actionButton(t('squadChat'), () => Nav.navigate('Chat'), 'navy'),
                          const SizedBox(width: 9),
                          _actionButton(t('leave'), () => _leave(m), 'danger'),
                        ],
                      ),
                    ],
                  ),
                )
              else
                EhCard(
                  margin: cardMargin,
                  padding: cardPad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardHeader(
                        m.pitch,
                        StatusPill(
                          label: '${t('played')} · ${fmt.dateShort(m.kickoff).toUpperCase()}',
                          bg: c.tint,
                          fg: c.ink55,
                          size: 10.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Txt(
                        '${pick('Final squad', 'الفريق النهائي')} ${m.joined}/${m.total} · ${pick('organized by', 'تنظيم')} ${pick(m.org, m.orgAr).split(' ').first}',
                        size: 12.5,
                        color: c.ink55,
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          _actionButton(
                            t('rate'),
                            () => _info(t('rate'), pick('Player ratings are coming soon.', 'تقييم اللاعيبة جاي قريب.')),
                            'outline',
                          ),
                        ],
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
