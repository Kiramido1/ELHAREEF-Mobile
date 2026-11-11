// Validation rules for sign-in / sign-up input. Pure Dart.

abstract final class EgyptianPhone {
  /// Egyptian mobile prefixes (Vodafone 10, Etisalat 11, Orange 12, WE 15).
  static final _national = RegExp(r'^1[0125]\d{8}$');

  /// Digits only, without the +20 country code or the trunk 0:
  /// "010 1234 5678", "+20 10-1234-5678" → "1012345678". Null when invalid.
  static String? normalize(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0020')) d = d.substring(4);
    if (d.length == 12 && d.startsWith('20')) d = d.substring(2);
    if (d.length == 11 && d.startsWith('0')) d = d.substring(1);
    return _national.hasMatch(d) ? d : null;
  }

  static bool isValid(String input) => normalize(input) != null;

  /// "+20 10 1234 5678".
  static String display(String national) => national.length == 10
      ? '+20 ${national.substring(0, 2)} ${national.substring(2, 6)} ${national.substring(6)}'
      : '+20 $national';
}

abstract final class CredentialRules {
  static const minPasswordLength = 6;
  static bool isValidPassword(String pw) => pw.length >= minPasswordLength;

  /// At least two letters, letters/spaces/hyphens/apostrophes only.
  static bool isValidName(String name) {
    final n = name.trim();
    return n.length >= 2 && RegExp(r"^[\p{L}][\p{L}\s'\-]*$", unicode: true).hasMatch(n);
  }
}
