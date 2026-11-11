// Port of src/screens/SettingsScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Txt(text.toUpperCase(), w: 700, size: 11.5, color: context.colors.ink4, letterSpacing: 0.8),
      );
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> _toggles = {'rem': true, 'upd': true, 'mkt': false};

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = context.watch<ThemeController>();
    final i18n = context.i18n;

    final notifRows = [
      (key: 'rem', label: i18n.t('remLabel'), sub: i18n.t('remSub')),
      (key: 'upd', label: i18n.t('updLabel'), sub: i18n.t('updSub')),
      (key: 'mkt', label: i18n.t('mktLabel'), sub: i18n.t('mktSub')),
    ];

    Widget labelSub(String label, String sub) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Txt(label, w: 600, size: 14),
            const SizedBox(height: 2),
            Txt(sub, size: 12, color: c.ink5),
          ],
        );

    BoxDecoration? divider(bool on) =>
        on ? BoxDecoration(border: Border(bottom: BorderSide(color: c.ink06, width: 1))) : null;

    Widget card(Widget child) => Padding(
          padding: const EdgeInsets.only(top: 9),
          child: EhCard(radius: Radii.card17, child: child),
        );

    Widget langOption(String value, String label, {bool ar = false}) {
      final on = i18n.lang == value;
      return Press(
        onTap: () => context.read<I18n>().setLang(value),
        scale: 1,
        selected: on,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: on ? c.navyBtn : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Txt(label, ar: ar, w: 700, size: 12, color: on ? Colors.white : c.ink6),
        ),
      );
    }

    Widget generalRow(String label, Widget trailing, {bool border = true, VoidCallback? onTap}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
            decoration: divider(border),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Txt(label, w: 600, size: 14)),
                trailing,
              ],
            ),
          ),
        );
    void soon() => showToast(i18n.t('comingSoon'));

    return Screen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EhBackButton(onPressed: Nav.back),
                const SizedBox(width: 12),
                Txt(i18n.t('settingsTitle'), w: 800, size: 18),
              ],
            ),

            _SectionLabel(i18n.t('secAppear')),
            card(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: labelSub(i18n.t('dark'), i18n.t('darkSub'))),
                    ToggleSwitch(value: theme.dark, onToggle: context.read<ThemeController>().toggleDark),
                  ],
                ),
              ),
            ),

            _SectionLabel(i18n.t('notifTitle')),
            card(
              Column(
                children: [
                  for (var i = 0; i < notifRows.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 17),
                      decoration: divider(i < notifRows.length - 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: labelSub(notifRows[i].label, notifRows[i].sub)),
                          ToggleSwitch(
                            value: _toggles[notifRows[i].key]!,
                            onToggle: () => setState(
                              () => _toggles[notifRows[i].key] = !_toggles[notifRows[i].key]!,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            _SectionLabel(i18n.t('secGeneral')),
            card(
              Column(
                children: [
                  generalRow(
                    i18n.t('language'),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.md)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          langOption('en', 'English'),
                          const SizedBox(width: 5),
                          langOption('ar', 'العربية', ar: true),
                        ],
                      ),
                    ),
                  ),
                  generalRow(
                    i18n.t('paymentMethods'),
                    Txt('${i18n.t('cashSub')} ›', size: 12, color: c.ink45),
                    onTap: soon,
                  ),
                  generalRow(
                    i18n.t('privacy'),
                    Txt('${i18n.t('pubProfile')} ›', size: 12, color: c.ink45),
                    onTap: soon,
                  ),
                  generalRow(i18n.t('help'), Txt('›', size: 16, color: c.ink3), border: false, onTap: soon),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Txt(i18n.t('version'), size: 11.5, color: c.ink4, center: true),
          ],
        ),
      ),
    );
  }
}
