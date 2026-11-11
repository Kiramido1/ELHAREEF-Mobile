// Lightweight DI: controllers are provided with InheritedNotifier scopes.
// `context.watch<T>()` rebuilds on change; `context.read<T>()` does not
// (use it in callbacks). The object graph is assembled in app/di.dart.
import 'package:flutter/widgets.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/theme_controller.dart';

export 'package:elhareef/core/theme/theme_controller.dart';

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
