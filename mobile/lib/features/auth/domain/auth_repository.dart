import 'package:oblns/core/models/user_model.dart';

/// Repository interface for authentication
/// UI should only interact with this interface, never with data sources directly
abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<void> verifyOtp(String phone, String otp);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();

  // Extended methods (available in HybridAuthRepository)
  Future<void> sendEmailOtp(String email);
  Future<void> verifyEmailOtp(String email, String otp);
  Future<void> signInWithGoogle();
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  });
}
