import 'package:elhareef/core/error/failures.dart';
import 'package:elhareef/features/auth/domain/entities/credentials.dart';
import 'package:elhareef/features/auth/domain/entities/user_session.dart';
import 'package:elhareef/features/auth/domain/repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._repo);
  final AuthRepository _repo;

  Future<UserSession> call({required String phone, required String password}) {
    final national = EgyptianPhone.normalize(phone);
    if (national == null) throw const ValidationError('phone');
    if (!CredentialRules.isValidPassword(password)) throw const ValidationError('password');
    return _repo.signIn(phone: national, password: password);
  }
}

class SignUp {
  const SignUp(this._repo);
  final AuthRepository _repo;

  Future<UserSession> call({required String name, required String phone, required String password}) {
    final national = EgyptianPhone.normalize(phone);
    if (!CredentialRules.isValidName(name)) throw const ValidationError('name');
    if (national == null) throw const ValidationError('phone');
    if (!CredentialRules.isValidPassword(password)) throw const ValidationError('password');
    return _repo.signUp(name: name.trim(), phone: national, password: password);
  }
}
