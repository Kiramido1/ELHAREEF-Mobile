// Port of src/i18n/index.tsx.
import 'package:flutter/foundation.dart';

import 'translations.dart' as tr;

export 'translations.dart' show typeAr, areaAr, dayAr, levelAr;

class I18n extends ChangeNotifier {
  String lang = 'en';
  bool get isRTL => lang == 'ar';

  void setLang(String value) {
    lang = value;
    notifyListeners();
  }

  /// Look up a string in the current language.
  String t(String key) {
    final s = (isRTL ? tr.ar : tr.en)[key];
    assert(s != null, 'Missing translation key: $key');
    return s ?? key;
  }

  /// Pick between raw English/Arabic strings (for data-layer values).
  String pick(String english, String arabic) => isRTL ? arabic : english;
}
