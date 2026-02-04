import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/features/auth/domain/auth_repository.dart';
import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/features/auth/infrastructure/appwrite_auth_repository.dart';

import 'package:oblns/core/utils/error_messages.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  otpSent,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;
  final String? phoneNumber;
  final String? email;

  AuthState({
    required this.status,
    this.errorMessage,
    this.user,
    this.phoneNumber,
    this.email,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
    String? phoneNumber,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial();

  AuthRepository get _repository => ref.watch(authRepositoryProvider);

  Future<void> sendOtp({String? phone, String? email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      if (phone != null) {
        await _repository.sendOtp(phone);
        state = state.copyWith(status: AuthStatus.otpSent, phoneNumber: phone);
      } else if (email != null) {
        await _repository.sendEmailOtp(email);
        state = state.copyWith(status: AuthStatus.otpSent, email: email);
      } else {
        throw Exception('يجب إدخال رقم الهاتف أو البريد الإلكتروني');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> verifyOtp(String otp, {String? name, String? email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      if (state.phoneNumber != null) {
        await _repository.verifyOtp(state.phoneNumber!, otp);
      } else if (state.email != null) {
        await _repository.verifyEmailOtp(state.email!, otp);
      } else {
        throw Exception('لم يتم إرسال رمز التحقق');
      }

      final user = await _repository.getCurrentUser();

      if (user != null && (name != null || email != null)) {
        // AppLogger isn't imported but error_messages is. We can just log via print or ignore logging for now to avoid import errors if AppLogger is not available.
        // Actually I saw logging_config in imports in Step 169 attempt, let's check imports.
        // Step 143 showed imports: flutter_riverpod, auth_repository, user_model, appwrite_auth_repository, error_messages.
        // No AppLogger. I will skip logging or just use print for now.
        await _repository.updateUserProfile(name: name, email: email);
        final updatedUser = await _repository.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: updatedUser,
        );
      } else {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _repository.signInWithGoogle();
      final user = await _repository.getCurrentUser();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    return ErrorMessages.getArabicMessage(error);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
