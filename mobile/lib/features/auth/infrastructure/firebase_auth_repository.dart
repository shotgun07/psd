import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/core/firebase_config.dart';
import 'package:oblns/features/auth/domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn? _googleSignIn;

  String? _verificationId;

  FirebaseAuthRepository(this._auth, this._firestore, this._googleSignIn);

  @override
  Future<void> sendOtp(String phone) async {
    final completer = Completer<void>();
    try {
      String formattedPhone = phone.startsWith('+') ? phone : '+218$phone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _createUserIfNotExists();
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(e.message ?? 'فشل التحقق من رقم الهاتف'),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete();
        },
      );
      await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('لم يتم إرسال رمز التحقق');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _createUserIfNotExists();
    } catch (e) {
      throw Exception('رمز التحقق غير صحيح');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google Sign In temporarily disabled');
    // if (_googleSignIn == null) {
    //   throw Exception('تسجيل الدخول بواسطة Google غير متاح حالياً');
    // }
    // try {
    //   final googleUser = await _googleSignIn.signIn();
    //   if (googleUser == null) {
    //     throw Exception('تم إلغاء تسجيل الدخول');
    //   }
    //   final googleAuth = await googleUser.authentication;
    //   final credential = GoogleAuthProvider.credential(
    //     accessToken: googleAuth.accessToken,
    //     idToken: googleAuth.idToken,
    //   );
    //   await _auth.signInWithCredential(credential);
    //   await _createUserIfNotExists();
    // } catch (e) {
    //   throw Exception('فشل تسجيل الدخول بواسطة Google: $e');
    // }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    throw UnimplementedError('Email OTP not implemented');
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    throw UnimplementedError('Email OTP verification not implemented');
  }

  /// Create user document if it doesn't exist
  Future<void> _createUserIfNotExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .set({
            'name': user.displayName ?? 'مستخدم جديد',
            'phone': user.phoneNumber ?? '',
            'email': user.email,
            'wallet_balance': 0.0,
            'rating': 5.0,
            'role': 'client',
            'kyc_status': 'pending',
            'profile_image_url': user.photoURL,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    try {
      if (_googleSignIn != null) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
  }

  /// Update user profile
  @override
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('المستخدم غير مسجل الدخول');

    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

    await _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(user.uid)
        .update(updates);

    // Update Firebase Auth profile
    if (name != null || profileImageUrl != null) {
      await user.updateDisplayName(name);
      await user.updatePhotoURL(profileImageUrl);
    }
  }

  /// Get user stream
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromJson({'id': doc.id, ...doc.data()!});
        });
  }

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(googleSignInProvider),
  );
});
