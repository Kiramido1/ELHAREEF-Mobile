// Port of src/screens/ProfileScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/input.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/features/auth/domain/entities/credentials.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/widgets/ui.dart';

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

  Future<void> _editName(BuildContext context, String current) async {
    final i18n = context.i18n;
    final c = context.colors;
    final ctrl = TextEditingController(text: current);
    var invalid = false;
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: c.card,
          title: Txt(i18n.t('editName'), w: 700, size: 17),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Input(controller: ctrl, autofocus: true, maxLength: 40, error: invalid),
              if (invalid)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Txt(i18n.t('nameError'), size: 12, color: Brand.danger),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Txt(i18n.t('cancel'), w: 600, size: 14, color: c.ink55),
            ),
            TextButton(
              onPressed: () {
                if (!CredentialRules.isValidName(ctrl.text)) return setLocal(() => invalid = true);
                Navigator.of(ctx).pop(ctrl.text.trim());
              },
              child: Txt(i18n.t('save'), w: 700, size: 14, color: Brand.green),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (saved != null && context.mounted) await context.read<SessionController>().rename(saved);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;

    final session = context.watch<SessionController>();
    final user = session.session;
    final name = user?.name ?? 'Youssef Adel';
    final phone = user == null ? '' : EgyptianPhone.display(user.phone);
    final played = context.watch<MatchesController>().completed.length;
    final booked = context.watch<BookingsController>().total;
    void soon() => showToast(t('comingSoon'));

    final menu = <(String, String, VoidCallback)>[
      (t('paymentMethods'), t('cashSub'), soon),
      (t('notifTitle'), t('allOn'), () => Nav.navigate('Notifications')),
      (t('privacy'), t('pubProfile'), soon),
      (t('myReviews'), t('myReviewsSub'), soon),
      (t('help'), '', soon),
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
                Avatar(initial: user?.initial ?? 'Y', palette: 'navy', size: 70, fontSize: 24, borderColor: Brand.green),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Txt(name, w: 800, size: 20),
                      const SizedBox(height: 2),
                      if (phone.isNotEmpty) Directionality(textDirection: TextDirection.ltr, child: Txt(phone, size: 13, color: c.ink55)),
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
                    onTap: () => _editName(context, name),
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
                  child: _StatCard(value: '$played', label: t('matchesW')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(value: '$booked', label: t('bookingsW')),
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
              onTap: () async {
                await context.read<SessionController>().signOut();
                Nav.resetTo('Login');
              },
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
