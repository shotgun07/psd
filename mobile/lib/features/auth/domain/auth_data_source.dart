import 'package:oblns/core/models/user_model.dart';

/// Abstract data source interface for authentication
/// This allows us to swap implementations (Appwrite, Firebase, etc.)
abstract class AuthDataSource {
  Future<void> sendOtp(String phone);
  Future<void> sendEmailOtp(String email);
  Future<void> verifyOtp(String phone, String otp);
  Future<void> verifyEmailOtp(String email, String otp);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> signInWithGoogle();
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  });
}
