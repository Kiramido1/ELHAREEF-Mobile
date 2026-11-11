// Current language + string lookup. Persists the choice when given a store.
import 'package:flutter/foundation.dart';

import 'package:elhareef/core/i18n/formatters.dart';
import 'package:elhareef/core/i18n/translations.dart' as tr;
import 'package:elhareef/core/i18n/translations_app.dart' as tra;
import 'package:elhareef/core/storage/key_value_store.dart';

export 'package:elhareef/core/i18n/formatters.dart';
export 'package:elhareef/core/i18n/translations.dart' show typeAr, areaAr, dayAr, levelAr;

class I18n extends ChangeNotifier {
  I18n({KeyValueStore? store}) : _store = store, lang = store?.getString(_key) ?? 'en';

  static const _key = 'settings.lang';
  final KeyValueStore? _store;
  String lang;

  bool get isRTL => lang == 'ar';
  Formatters get fmt => Formatters(arabic: isRTL);

  void setLang(String value) {
    if (value == lang) return;
    lang = value;
    _store?.setString(_key, value);
    notifyListeners();
  }

  /// Look up a string in the current language.
  String t(String key) {
    final s = isRTL ? (tr.ar[key] ?? tra.arApp[key]) : (tr.en[key] ?? tra.enApp[key]);
    assert(s != null, 'Missing translation key: $key');
    return s ?? key;
  }

  /// Pick between raw English/Arabic strings (for data-layer values).
  String pick(String english, String arabic) => isRTL ? arabic : english;
}
