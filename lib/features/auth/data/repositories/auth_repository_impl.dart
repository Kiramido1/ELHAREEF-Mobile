// Mock auth: any valid credentials sign in. The session (never the
// password) is stored on-device so the user stays logged in.
import 'dart:convert';

import 'package:elhareef/core/network/fake_network.dart';
import 'package:elhareef/core/storage/key_value_store.dart';
import 'package:elhareef/features/auth/domain/entities/user_session.dart';
import 'package:elhareef/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._store) : _session = _read(_store);

  static const _sessionKey = 'auth.session.v1';
  static const _onboardingKey = 'auth.onboardingSeen';
  static const _namesKey = 'auth.names.v1';

  /// Name shown for a phone that signs in without having signed up here.
  static const defaultName = 'Youssef Adel';

  final KeyValueStore _store;
  UserSession? _session;

  static UserSession? _read(KeyValueStore store) {
    final raw = store.getString(_sessionKey);
    if (raw == null) return null;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      return UserSession(name: j['name']! as String, phone: j['phone']! as String);
    } on Object {
      return null;
    }
  }

  Map<String, String> get _names {
    try {
      return ((jsonDecode(_store.getString(_namesKey) ?? '{}') as Map).cast<String, String>());
    } on Object {
      return {};
    }
  }

  Future<UserSession> _save(UserSession s) async {
    _session = s;
    await _store.setString(_sessionKey, jsonEncode({'name': s.name, 'phone': s.phone}));
    await _store.setString(_namesKey, jsonEncode({..._names, s.phone: s.name}));
    return s;
  }

  @override
  UserSession? get currentSession => _session;

  @override
  bool get onboardingSeen => _store.getBool(_onboardingKey) ?? false;

  @override
  Future<void> markOnboardingSeen() => _store.setBool(_onboardingKey, true);

  @override
  Future<UserSession> signIn({required String phone, required String password}) async {
    await simulateRequest(null, 600);
    return _save(UserSession(name: _names[phone] ?? defaultName, phone: phone));
  }

  @override
  Future<UserSession> signUp({required String name, required String phone, required String password}) async {
    await simulateRequest(null, 700);
    return _save(UserSession(name: name, phone: phone));
  }

  @override
  Future<void> signOut() async {
    _session = null;
    await _store.remove(_sessionKey);
  }

  @override
  Future<UserSession> updateName(String name) async {
    final s = _session;
    if (s == null) throw const ValidationError('session');
    return _save(UserSession(name: name.trim(), phone: s.phone));
  }
}
