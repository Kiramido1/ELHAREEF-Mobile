import 'package:flutter/foundation.dart';

import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/features/auth/domain/entities/credentials.dart';
import 'package:elhareef/features/auth/domain/entities/user_session.dart';
import 'package:elhareef/features/auth/domain/repositories/auth_repository.dart';
import 'package:elhareef/features/auth/domain/usecases/sign_in.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._repo)
      : _signIn = SignIn(_repo),
        _signUp = SignUp(_repo);

  final AuthRepository _repo;
  final SignIn _signIn;
  final SignUp _signUp;
  bool busy = false;

  UserSession? get session => _repo.currentSession;
  bool get signedIn => session != null;
  bool get onboardingSeen => _repo.onboardingSeen;

  /// Display name, falling back to the demo user before sign-in.
  String get firstName => session?.firstName ?? 'Youssef';

  Future<void> completeOnboarding() => _repo.markOnboardingSeen();

  Future<bool> signIn(String phone, String password) => _run(() => _signIn(phone: phone, password: password));
  Future<bool> signUp(String name, String phone, String password) =>
      _run(() => _signUp(name: name, phone: phone, password: password));

  Future<bool> rename(String name) async {
    if (!CredentialRules.isValidName(name)) return false;
    return _run(() => _repo.updateName(name));
  }

  Future<void> signOut() async {
    await _repo.signOut();
    notifyListeners();
  }

  Future<bool> _run(Future<UserSession> Function() action) async {
    if (busy) return false;
    busy = true;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppFailure {
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
