// Port of src/screens/NotificationsScreen.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/features/profile/data/datasources/players_mock_datasource.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/features/profile/domain/entities/notification_item.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({super.key, required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final dotColor = switch (item.dot) {
      'green' => Brand.green,
      'lime' => Brand.lime,
      'danger' => Brand.danger,
      _ => c.ink25,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
      decoration: BoxDecoration(
        color: item.unread ? c.tint : c.card,
        border: Border.all(color: c.ink08, width: 1),
        borderRadius: BorderRadius.circular(Radii.card15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Txt(i18n.pick(item.text, item.textAr), size: 13.5, lineHeight: 20),
                const SizedBox(height: 3),
                Txt(i18n.pick(item.time, item.timeAr), w: 600, size: 11.5, color: c.ink45),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Txt(text.toUpperCase(), w: 700, size: 11.5, color: c.ink4, letterSpacing: 0.8),
        );

    Widget group(List<NotificationItem> items) => Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 9),
                _NotificationRow(key: ValueKey(items[i].id), item: items[i]),
              ],
            ],
          ),
        );

    return Screen(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: Layout.screenX, right: Layout.screenX, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EhBackButton(onPressed: Nav.back),
                const SizedBox(width: 12),
                Txt(i18n.t('notifTitle'), w: 800, size: 18),
              ],
            ),
            label(i18n.t('today')),
            group(notificationsToday),
            label(i18n.t('earlier')),
            group(notificationsEarlier),
          ],
        ),
      ),
    );
  }
}
