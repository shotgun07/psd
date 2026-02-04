import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oblns/core/models/user_model.dart';
import 'package:oblns/core/firebase_config.dart';
import 'package:oblns/features/auth/domain/auth_data_source.dart';

class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final dynamic _googleSignIn;

  String? _verificationId;

  FirebaseAuthDataSource(this._auth, this._firestore, this._googleSignIn);

  @override
  Future<void> sendOtp(String phone) async {
    try {
      String formattedPhone = phone.startsWith('+') ? phone : '+218$phone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _createUserIfNotExists();
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(_mapFirebaseError(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      throw Exception('خطأ في إرسال رمز التحقق: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      // Firebase standard doesn't support 6-digit OTP for email natively.
      // We use email link or password. For "Free Tier" request with "OTP" labels,
      // we suggest using password flow or custom functions.
      // Here we implement it as a friendly error message until custom backend is ready.
      throw Exception(
        'خاصية رمز البريد الإلكتروني ستتوفر قريباً. يرجى استخدام رقم الهاتف أو جوجل حالياً.',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('لم يتم إرسال رمز التحقق. يرجى المحاولة مرة أخرى.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _createUserIfNotExists();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (e) {
      throw Exception('رمز التحقق غير صحيح');
    }
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    throw UnimplementedError(
      'خاصية التحقق من البريد الإلكتروني عبر الرمز غير متوفرة حالياً في النسخة المجانية',
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    if (_googleSignIn == null) {
      throw Exception('Google Sign-In not available on this platform');
    }
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('تم إلغاء عملية تسجيل الدخول');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      await _createUserIfNotExists();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بواسطة Google');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('فشل تسجيل الخروج');
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
      if (name != null) await user.updateDisplayName(name);
      if (profileImageUrl != null) await user.updatePhotoURL(profileImageUrl);
    }
  }

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

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'operation-not-allowed':
        return 'عملية تسجيل الدخول هذه غير مفعلة حالياً';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الجلسة. يرجى طلب رمز جديد';
      case 'network-request-failed':
        return 'يوجد مشكلة في الاتصال بالإنترنت';
      default:
        return 'حدث خطأ في عملية المصادقة. يرجى المحاولة مرة أخرى';
    }
  }
}
