import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/features/auth/domain/auth_repository.dart';
import 'package:oblns/features/auth/domain/auth_data_source.dart';

class HybridAuthRepository implements AuthRepository {
  final AuthDataSource _primary;
  final AuthDataSource _fallback;

  bool _primaryAvailable = true;
  DateTime? _lastPrimaryFailure;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 5);

  HybridAuthRepository({
    required AuthDataSource primary,
    required AuthDataSource fallback,
  }) : _primary = primary,
       _fallback = fallback;

  bool get _shouldUsePrimary {
    if (_primaryAvailable) return true;
    if (_lastPrimaryFailure == null) return true;

    final timeSinceFailure = DateTime.now().difference(_lastPrimaryFailure!);
    if (timeSinceFailure > _circuitBreakerTimeout) {
      _primaryAvailable = true;
      return true;
    }
    return false;
  }

  Future<T> _executeWithFallback<T>(
    Future<T> Function(AuthDataSource) operation,
  ) async {
    if (_shouldUsePrimary) {
      try {
        return await operation(_primary);
      } catch (e) {
        _primaryAvailable = false;
        _lastPrimaryFailure = DateTime.now();
      }
    }

    try {
      return await operation(_fallback);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    await _executeWithFallback((source) => source.sendOtp(phone));
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    await _executeWithFallback((source) => source.verifyOtp(phone, otp));
  }

  @override
  Future<void> logout() async {
    try {
      await _primary.logout();
    } catch (_) {}
    try {
      await _fallback.logout();
    } catch (_) {}
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final primaryUser = await _primary.getCurrentUser();
    if (primaryUser != null) return primaryUser;

    return await _fallback.getCurrentUser();
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    await _executeWithFallback((source) => source.sendEmailOtp(email));
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    await _executeWithFallback((source) => source.verifyEmailOtp(email, otp));
  }

  @override
  Future<void> signInWithGoogle() async {
    await _executeWithFallback((source) => source.signInWithGoogle());
  }

  @override
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    await _executeWithFallback(
      (source) => source.updateUserProfile(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
      ),
    );
  }
}
