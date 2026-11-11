import 'package:flutter/foundation.dart';

import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/core/theme/colors.dart';

/// Light/dark palette selection, persisted when given a store.
class ThemeController extends ChangeNotifier {
  ThemeController({KeyValueStore? store}) : _store = store, dark = store?.getBool(_key) ?? false;

  static const _key = 'settings.dark';
  final KeyValueStore? _store;
  bool dark;

  ThemeColors get colors => dark ? darkColors : lightColors;

  void toggleDark() {
    dark = !dark;
    _store?.setBool(_key, dark);
    notifyListeners();
  }
}
