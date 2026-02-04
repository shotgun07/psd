import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';
import 'package:oblns/features/auth/domain/auth_repository.dart';
import 'package:oblns/features/auth/infrastructure/data_sources/appwrite_auth_data_source.dart';
import 'package:oblns/features/auth/infrastructure/data_sources/firebase_auth_data_source.dart';
import 'package:oblns/features/auth/infrastructure/hybrid_auth_repository.dart';
import 'package:oblns/core/firebase_config.dart';

/// Legacy Appwrite-only repository (kept for backward compatibility)
/// New code should use HybridAuthRepository via authRepositoryProvider
class AppwriteAuthRepository implements AuthRepository {
  final Account _account;
  final Functions _functions;

  AppwriteAuthRepository(this._account, this._functions);

  @override
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    // TODO: Implement actual Appwrite update
    throw UnimplementedError('Appwrite profile update not implemented yet');
  }

  @override
  Future<void> sendOtp(String phone) async {
    await _functions.createExecution(
      functionId: 'otpHandler',
      body: '{"action": "send", "phone": "$phone"}',
    );
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    final execution = await _functions.createExecution(
      functionId: 'otpHandler',
      body: '{"action": "verify", "phone": "$phone", "otp": "$otp"}',
    );

    if (execution.status.toString() != 'completed') {
      throw Exception('Verification failed');
    }
  }

  @override
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
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
  Future<void> sendEmailOtp(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }
}

/// Data source providers
final appwriteAuthDataSourceProvider = Provider<AppwriteAuthDataSource>((ref) {
  final account = ref.watch(appwriteAccountProvider);
  final functions = ref.watch(appwriteFunctionsProvider);
  return AppwriteAuthDataSource(account, functions);
});

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return FirebaseAuthDataSource(auth, firestore, null);
});

/// Main repository provider - uses hybrid pattern with fallback
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final appwriteSource = ref.watch(appwriteAuthDataSourceProvider);
  final firebaseSource = ref.watch(firebaseAuthDataSourceProvider);

  return HybridAuthRepository(
    primary: firebaseSource,
    fallback: appwriteSource,
  );
});
