class UserSession {
  const UserSession({required this.name, required this.phone});
  final String name;

  /// Normalised national number, 10 digits (e.g. 1012345678).
  final String phone;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
  String get initial => name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();
}
