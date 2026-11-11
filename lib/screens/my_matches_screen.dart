// Port of src/screens/MyMatchesScreen.tsx.
import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

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

  /// RN `Alert.alert` (OS dialog). [buttons]: (label, destructive); defaults to a single OK.
  void _alert(String title, String message, [List<(String, bool)>? buttons]) {
    final c = context.colors;
    final btns = buttons ?? [(MaterialLocalizations.of(context).okButtonLabel, false)];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        title: Txt(title, w: 700, size: 17),
        content: Txt(message, size: 14, color: c.ink7),
        actions: [
          for (final (label, destructive) in btns)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Txt(label, w: 600, size: 14, color: destructive ? Brand.danger : Brand.green),
            ),
        ],
      ),
    );
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
            if (_tab == 0)
              EhCard(
                lime: true,
                margin: cardMargin,
                padding: cardPad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(
                      'Dream Sports Arena',
                      StatusPill(label: t('hosting'), bg: c.limeChip, fg: c.limeChipFg, size: 10.5, weight: 800),
                    ),
                    const SizedBox(height: 5),
                    Txt(t('mm1'), size: 12.5, color: c.ink55),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        const Expanded(child: ProgressBar(pct: 87.5, height: 7)),
                        const SizedBox(width: 12),
                        Txt('7/8', w: 800, size: 13),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Txt(t('mm2'), w: 700, size: 12.5, color: Brand.green),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _actionButton(t('squadChat'), () => Nav.navigate('Chat'), 'outline'),
                        const SizedBox(width: 9),
                        _actionButton(t('openMatch'), () => Nav.navigate('MatchDetails', 0), 'navy', flex: 14),
                      ],
                    ),
                  ],
                ),
              ),
            if (_tab == 1)
              EhCard(
                margin: cardMargin,
                padding: cardPad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(
                      'Green Field Club',
                      StatusPill(label: t('joinedChip'), bg: c.tint, fg: Brand.green, size: 10.5, weight: 800),
                    ),
                    const SizedBox(height: 5),
                    Txt(t('mm3'), size: 12.5, color: c.ink55),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _actionButton(t('squadChat'), () => Nav.navigate('Chat'), 'navy'),
                        const SizedBox(width: 9),
                        _actionButton(
                          t('leave'),
                          () => _alert(t('leave'), pick('Leave this match?', 'تنسحب من الماتش ده؟'), [
                            (pick('Stay', 'خليك'), false),
                            (t('leave'), true),
                          ]),
                          'danger',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_tab == 2)
              EhCard(
                margin: cardMargin,
                padding: cardPad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader('Champions Park', StatusPill(label: t('played'), bg: c.tint, fg: c.ink55, size: 10.5)),
                    const SizedBox(height: 5),
                    Txt(t('mm4'), size: 12.5, color: c.ink55),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _actionButton(
                          t('rate'),
                          () => _alert(t('rate'), pick('Player ratings are coming soon.', 'تقييم اللاعيبة جاي قريب.')),
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
