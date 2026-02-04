import 'package:oblns/core/models/user_model.dart';

abstract class AuthService {
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get onAuthStateChanged;
}
