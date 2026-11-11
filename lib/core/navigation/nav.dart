// Navigation helpers mirroring React Navigation's semantics used by the RN
// app: one root stack (instant switch, no transition — ScreenEntrance plays
// the motion) plus a bottom-tab screen named 'Tabs'.
import 'package:flutter/material.dart';

final navKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

/// Selected bottom tab (index into [tabNames]).
final tabIndex = ValueNotifier<int>(0);
const tabNames = ['Home', 'Discover', 'Bookings', 'MyMatches', 'Profile'];

/// Keeps the names of the routes on the root stack, bottom first.
class StackTracker extends NavigatorObserver {
  final stack = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => stack.add(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => stack.remove(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => stack.remove(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : stack.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) stack[i] = newRoute;
  }
}

final stackTracker = StackTracker();

class Nav {
  static NavigatorState get _nav => navKey.currentState!;

  /// React Navigation `navigate`: a tab name selects that tab (returning to
  /// the tab screen); a route already on the stack with the same args is
  /// returned to; anything else is pushed.
  static void navigate(String name, [Object? args]) {
    if (name == 'Tabs' || tabNames.contains(name)) {
      final tab = name == 'Tabs' ? args as String? : name;
      if (tab != null) tabIndex.value = tabNames.indexOf(tab);
      if (stackTracker.stack.any((r) => r.settings.name == 'Tabs')) {
        _nav.popUntil((r) => r.settings.name == 'Tabs');
      } else {
        _nav.pushNamed('Tabs');
      }
      return;
    }
    final existing = stackTracker.stack
        .where((r) => r.settings.name == name && r.settings.arguments == args);
    if (existing.isNotEmpty) {
      _nav.popUntil((r) => r == existing.last);
    } else {
      _nav.pushNamed(name, arguments: args);
    }
  }

  static void push(String name, [Object? args]) => _nav.pushNamed(name, arguments: args);

  /// React Navigation `replace`. For 'Tabs', [args] is the tab name.
  static void replace(String name, [Object? args]) {
    if (name == 'Tabs' && args is String) tabIndex.value = tabNames.indexOf(args);
    _nav.pushReplacementNamed(name, arguments: name == 'Tabs' ? null : args);
  }

  static void back() => _nav.maybePop();

  /// Drop everything above the tab screen, then push [name]. Used after a
  /// completed flow (e.g. a confirmed booking) so Back can't re-enter it.
  static void resetToTabsThen(String name, [Object? args]) {
    if (!stackTracker.stack.any((r) => r.settings.name == 'Tabs')) {
      _nav.pushNamedAndRemoveUntil('Tabs', (_) => false);
    }
    _nav.pushNamedAndRemoveUntil(name, (r) => r.settings.name == 'Tabs', arguments: args);
  }

  /// Replace the whole stack with [name] (sign-in / sign-out).
  static void resetTo(String name, [Object? args]) {
    if (name == 'Tabs' && args is String) tabIndex.value = tabNames.indexOf(args);
    _nav.pushNamedAndRemoveUntil(name, (_) => false, arguments: name == 'Tabs' ? null : args);
  }
}

/// Instant route (RN stack used `animation: 'none'`).
Route<dynamic> instantRoute(RouteSettings settings, Widget Function(BuildContext) builder) =>
    PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => builder(context),
    );
