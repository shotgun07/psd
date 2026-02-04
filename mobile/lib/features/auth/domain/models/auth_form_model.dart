enum AuthMethod { phone, email }

class AuthFormModel {
  final AuthMethod method;
  final String phone;
  final String email;
  final String otp;
  final bool agreedToTerms;

  const AuthFormModel({
    this.method = AuthMethod.phone,
    this.phone = '',
    this.email = '',
    this.otp = '',
    this.agreedToTerms = false,
  });

  AuthFormModel copyWith({
    AuthMethod? method,
    String? phone,
    String? email,
    String? otp,
    bool? agreedToTerms,
  }) {
    return AuthFormModel(
      method: method ?? this.method,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }

  bool get isValidPhone {
    // Libyan phone format: 09X XXXXXXX (10 digits starting with 09)
    final phoneRegex = RegExp(r'^09[0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }

  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool get isValidOtp {
    return otp.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(otp);
  }

  bool get canSendOtp {
    if (method == AuthMethod.phone) {
      return isValidPhone && agreedToTerms;
    } else {
      return isValidEmail && agreedToTerms;
    }
  }

  bool get canVerifyOtp {
    return isValidOtp;
  }

  String? get phoneError {
    if (phone.isEmpty) return null;
    if (!isValidPhone) {
      return 'رقم الهاتف غير صحيح. يجب أن يبدأ بـ 09 ويحتوي على 10 أرقام';
    }
    return null;
  }

  String? get emailError {
    if (email.isEmpty) return null;
    if (!isValidEmail) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? get otpError {
    if (otp.isEmpty) return null;
    if (!isValidOtp) {
      return 'الرمز يجب أن يكون 6 أرقام';
    }
    return null;
  }
}
