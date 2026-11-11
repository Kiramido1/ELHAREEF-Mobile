import 'package:elhareef/features/auth/domain/entities/user_session.dart';

abstract interface class AuthRepository {
  UserSession? get currentSession;
  bool get onboardingSeen;
  Future<void> markOnboardingSeen();

  /// [phone] is already normalised.
  Future<UserSession> signIn({required String phone, required String password});
  Future<UserSession> signUp({required String name, required String phone, required String password});
  Future<void> signOut();
  Future<UserSession> updateName(String name);
}
