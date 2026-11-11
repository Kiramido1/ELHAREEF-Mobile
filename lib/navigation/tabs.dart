// Bottom tabs (port of MainTabs in src/navigation/index.tsx and
// src/components/TabBar.tsx). Tabs mount lazily on first visit and stay
// alive, like React Navigation's bottom tabs.
import 'package:flutter/material.dart';

import '../scope.dart';
import '../screens/bookings_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_matches_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/colors.dart';
import '../widgets/anim.dart';
import '../widgets/icons.dart';
import '../widgets/txt.dart';
import 'nav.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  final _visited = <int>{};

  static Widget _screen(int i) => switch (i) {
        0 => const HomeScreen(),
        1 => const DiscoverScreen(),
        2 => const BookingsScreen(),
        3 => const MyMatchesScreen(),
        _ => const ProfileScreen(),
      };

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tabIndex,
        builder: (context, index, _) {
          _visited.add(index);
          return Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: index,
                  children: [
                    for (var i = 0; i < tabNames.length; i++)
                      TabActive(
                        active: i == index,
                        child: _visited.contains(i) ? _screen(i) : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              TabBar(index: index, onSelect: (i) => tabIndex.value = i),
            ],
          );
        },
      );
}

/// Bottom tab bar matching the design: 22px stroke icons + 10.5px labels.
class TabBar extends StatelessWidget {
  const TabBar({super.key, required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  static const _labelKeys = ['nav0', 'nav1', 'nav2', 'nav3', 'nav4'];

  static Widget _icon(int i, Color color) => switch (i) {
        0 => HomeIcon(size: 22, color: color),
        1 => SearchIcon(size: 22, color: color),
        2 => CalendarIcon(size: 22, color: color),
        3 => PlayersIcon(size: 22, color: color),
        _ => ProfileIcon(size: 22, color: color),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(color: c.bar, border: Border(top: BorderSide(color: c.ink08))),
      padding: EdgeInsets.only(top: 9, left: 8, right: 8, bottom: (bottom > 12 ? bottom : 12) + 10),
      child: Row(
        children: [
          for (var i = 0; i < tabNames.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                label: i18n.t(_labelKeys[i]),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != index) onSelect(i);
                  },
                  child: Column(
                    children: [
                      _TabIcon(focused: i == index, child: _icon(i, i == index ? Brand.green : c.ink4)),
                      const SizedBox(height: 4),
                      Txt(i18n.t(_labelKeys[i]), w: 700, size: 10.5, color: i == index ? Brand.green : c.ink4, center: true),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Subtle spring pop on the icon when its tab becomes active.
class _TabIcon extends StatefulWidget {
  const _TabIcon({required this.focused, required this.child});
  final bool focused;
  final Widget child;
  @override
  State<_TabIcon> createState() => _TabIconState();
}

class _TabIconState extends State<_TabIcon> with SingleTickerProviderStateMixin {
  // RN Animated.spring(friction 5, tension 90) ≈ underdamped elasticOut.
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600), value: 1);

  @override
  void didUpdateWidget(_TabIcon old) {
    super.didUpdateWidget(old);
    if (widget.focused && !old.focused) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) =>
            Transform.scale(scale: 0.8 + 0.2 * const ElasticOutCurve(0.5).transform(_c.value), child: child),
      );
}
