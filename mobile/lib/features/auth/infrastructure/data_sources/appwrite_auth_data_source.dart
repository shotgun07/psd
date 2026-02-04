import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/features/auth/domain/auth_data_source.dart';

class AppwriteAuthDataSource implements AuthDataSource {
  final Account _account;
  final Functions _functions;

  AppwriteAuthDataSource(this._account, this._functions);

  @override
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    // TODO: Implement using Account API or Functions
    throw UnimplementedError('Appwrite profile update is not implemented yet.');
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await _functions.createExecution(
        functionId: 'otpHandler',
        body: '{"action": "send", "phone": "$phone"}',
      );
    } catch (e) {
      throw Exception('فشل إرسال رمز التحقق: $e');
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      await _functions.createExecution(
        functionId: 'otpHandler',
        body: '{"action": "send", "email": "$email"}',
      );
    } catch (e) {
      throw Exception('فشل إرسال رمز التحقق: $e');
    }
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final execution = await _functions.createExecution(
        functionId: 'otpHandler',
        body: '{"action": "verify", "phone": "$phone", "otp": "$otp"}',
      );

      if (execution.status.toString() != 'completed') {
        throw Exception('فشل التحقق من الرمز');
      }
    } catch (e) {
      throw Exception('رمز التحقق غير صحيح');
    }
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      final execution = await _functions.createExecution(
        functionId: 'otpHandler',
        body: '{"action": "verify", "email": "$email", "otp": "$otp"}',
      );

      if (execution.status.toString() != 'completed') {
        throw Exception('فشل التحقق من الرمز');
      }
    } catch (e) {
      throw Exception('رمز التحقق غير صحيح');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return UserModel.fromJson(user.toMap());
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _account.createOAuth2Session(provider: OAuthProvider.google);
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بواسطة Google: $e');
    }
  }
}
