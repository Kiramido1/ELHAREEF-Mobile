// Port of src/screens/ProfileScreen.tsx.
import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.valueColor});
  final String value, label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => EhCard(
    radius: Radii.card15,
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Txt(value, w: 800, size: 19, color: valueColor, center: true),
        const SizedBox(height: 2),
        Txt(label, w: 600, size: 11, color: context.colors.ink55, center: true),
      ],
    ),
  );
}

/// Menu row: RN Pressable whose background turns tint while pressed.
class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.label, required this.sub, required this.onTap, required this.last});
  final String label, sub;
  final VoidCallback onTap;
  final bool last;
  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _down = false;
  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 17),
          decoration: BoxDecoration(
            color: _down ? c.tint : c.card,
            border: widget.last ? null : Border(bottom: BorderSide(color: c.ink06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Txt(widget.label, w: 600, size: 14)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.sub.isNotEmpty) ...[Txt(widget.sub, size: 12, color: c.ink45), const SizedBox(width: 8)],
                  Txt('›', size: 16, color: c.ink3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;

    final menu = <(String, String, VoidCallback)>[
      (t('paymentMethods'), t('cashSub'), () => Nav.navigate('Settings')),
      (t('notifTitle'), t('allOn'), () => Nav.navigate('Notifications')),
      (t('privacy'), t('pubProfile'), () => Nav.navigate('Settings')),
      (t('myReviews'), t('myReviewsSub'), () => Nav.navigate('PlayerProfile', 0)),
      (t('help'), '', () => Nav.navigate('Settings')),
      (t('settingsTitle'), '', () => Nav.navigate('Settings')),
    ];

    Widget pill(String label, Color bg, Color? fg) => Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Txt(label, w: 700, size: 11.5, color: fg),
    );

    return Screen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: EhBackButton(onPressed: () => Nav.navigate('Home')),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Avatar(initial: 'Y', palette: 'navy', size: 70, fontSize: 24, borderColor: Brand.green),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt('Youssef Adel', w: 800, size: 20),
                      const SizedBox(height: 2),
                      Txt('+20 10 1234 5678', size: 13, color: c.ink55),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          pill(t('midfielder'), c.tint, null),
                          const SizedBox(width: 6),
                          pill(t('intermediate'), c.limeChip, c.limeChipFg),
                        ],
                      ),
                    ],
                  ),
                ),
                // hitSlop 8: the tap target is padded by 8 on every side; the
                // gap is shrunk and the box shifted so the label sits where RN
                // draws it.
                const SizedBox(width: 15 - 8),
                Transform.translate(
                  offset: Offset(i18n.isRTL ? -8 : 8, 0),
                  child: Press(
                    onTap: () => Nav.navigate('Settings'),
                    scale: 1,
                    label: t('edit'),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Txt(t('edit'), w: 700, size: 13, color: Brand.green),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(value: '18', label: t('matchesW')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(value: '12', label: t('bookingsW')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(value: '★ 4.7', label: t('rating'), valueColor: Brand.green),
                ),
              ],
            ),
            EhCard(
              radius: Radii.card17,
              margin: const EdgeInsets.only(top: 18),
              child: ClipRRect(
                // Card radius minus its 1px border (RN overflow: hidden).
                borderRadius: BorderRadius.circular(Radii.card17 - 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, (label, sub, go)) in menu.indexed)
                      _MenuRow(label: label, sub: sub, onTap: go, last: i == menu.length - 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              // CommonActions.reset({ index: 0, routes: [{ name: 'Login' }] })
              onTap: () => navKey.currentState!.pushNamedAndRemoveUntil('Login', (_) => false),
              child: Semantics(
                button: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Txt(t('logout'), w: 600, size: 14, color: Brand.danger, center: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
