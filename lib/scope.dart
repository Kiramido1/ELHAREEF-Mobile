// App-wide state controllers, the Flutter stand-in for the RN Context
// providers. `context.watch<T>()` rebuilds on change; `context.read<T>()`
// does not (use it in callbacks).
import 'package:flutter/widgets.dart';

import 'i18n/i18n.dart';
import 'state/booking.dart';
import 'state/chat.dart';
import 'state/matches.dart';
import 'theme/colors.dart';

class ThemeController extends ChangeNotifier {
  bool dark = false;
  ThemeColors get colors => dark ? darkColors : lightColors;
  void toggleDark() {
    dark = !dark;
    notifyListeners();
  }
}

class Scope<T extends Listenable> extends InheritedNotifier<T> {
  const Scope({super.key, required T value, required super.child}) : super(notifier: value);
}

extension ScopeContext on BuildContext {
  T watch<T extends Listenable>() {
    final s = dependOnInheritedWidgetOfExactType<Scope<T>>();
    assert(s != null, 'No Scope<$T> above this widget');
    return s!.notifier!;
  }

  T read<T extends Listenable>() {
    final s = getInheritedWidgetOfExactType<Scope<T>>();
    assert(s != null, 'No Scope<$T> above this widget');
    return s!.notifier!;
  }

  /// Current theme colors (rebuilds on theme change).
  ThemeColors get colors => watch<ThemeController>().colors;

  /// Current i18n (rebuilds on language change).
  I18n get i18n => watch<I18n>();
}

/// Wraps the app in every state scope (mirrors App.tsx provider nesting).
class AppScopes extends StatefulWidget {
  const AppScopes({super.key, required this.child});
  final Widget child;

  @override
  State<AppScopes> createState() => _AppScopesState();
}

class _AppScopesState extends State<AppScopes> {
  final theme = ThemeController();
  final i18n = I18n();
  final booking = BookingController();
  final matches = MatchesController();
  final chat = ChatController();

  @override
  Widget build(BuildContext context) => Scope<ThemeController>(
        value: theme,
        child: Scope<I18n>(
          value: i18n,
          child: Scope<BookingController>(
            value: booking,
            child: Scope<MatchesController>(
              value: matches,
              child: Scope<ChatController>(value: chat, child: widget.child),
            ),
          ),
        ),
      );
}
