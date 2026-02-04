/// Validators for Libyan phone numbers and OTP codes
class LibyanPhoneValidator {
  static final RegExp _phoneRegex = RegExp(r'^09[0-9]{8}$');
  static final RegExp _phoneWithCodeRegex = RegExp(r'^\+?218[0-9]{9}$');

  /// Validates a Libyan phone number
  /// Accepts formats: 0912345678 or +218912345678
  static String? validate(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    // Remove spaces and dashes
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it matches Libyan format
    if (!_phoneRegex.hasMatch(cleaned) &&
        !_phoneWithCodeRegex.hasMatch(cleaned)) {
      return 'رقم الهاتف غير صحيح. يجب أن يبدأ بـ 09 ويحتوي على 10 أرقام';
    }

    return null;
  }

  /// Formats phone number to +218 format
  static String formatToInternational(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.startsWith('09')) {
      return '+218${cleaned.substring(1)}';
    }
    if (cleaned.startsWith('218')) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('+218')) {
      return cleaned;
    }
    return phone;
  }
}

/// Validator for OTP codes
class OTPValidator {
  static final RegExp _otpRegex = RegExp(r'^[0-9]{6}$');

  /// Validates a 6-digit OTP code
  static String? validate(String? otp) {
    if (otp == null || otp.isEmpty) {
      return 'الرجاء إدخال رمز التحقق';
    }

    if (otp.length != 6) {
      return 'رمز التحقق يجب أن يحتوي على 6 أرقام';
    }

    if (!_otpRegex.hasMatch(otp)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// Checks if OTP is complete (6 digits)
  static bool isComplete(String? otp) {
    return otp != null && otp.length == 6 && _otpRegex.hasMatch(otp);
  }
}

/// Validator for email addresses
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates an email address
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return null; // Email is optional
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// Checks if email is valid
  static bool isValid(String? email) {
    return email != null && email.isNotEmpty && _emailRegex.hasMatch(email);
  }
}

/// Validator for names
class NameValidator {
  static final RegExp _arabicNameRegex = RegExp(r'^[\u0621-\u064A\s]+$');
  static final RegExp _latinNameRegex = RegExp(r'^[a-zA-Z\s]+$');

  /// Validates a name (accepts Arabic or Latin characters)
  static String? validate(
    String? name, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (name == null || name.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }

    final trimmed = name.trim();

    if (trimmed.length < minLength) {
      return 'الاسم قصير جداً (الحد الأدنى $minLength أحرف)';
    }

    if (trimmed.length > maxLength) {
      return 'الاسم طويل جداً (الحد الأقصى $maxLength حرف)';
    }

    // Accept Arabic or Latin names
    if (!_arabicNameRegex.hasMatch(trimmed) &&
        !_latinNameRegex.hasMatch(trimmed)) {
      return 'الاسم يجب أن يحتوي على حروف عربية أو إنجليزية فقط';
    }

    return null;
  }
}

/// Validator for Libyan National ID
class LibyanNationalIdValidator {
  static final RegExp _nationalIdRegex = RegExp(r'^[0-9]{12}$');

  /// Validates Libyan National ID (12 digits)
  static String? validate(String? nationalId) {
    if (nationalId == null || nationalId.isEmpty) {
      return 'الرجاء إدخال الرقم الوطني';
    }

    final cleaned = nationalId.replaceAll(RegExp(r'[\s\-]'), '');

    if (!_nationalIdRegex.hasMatch(cleaned)) {
      return 'الرقم الوطني غير صحيح (يجب أن يحتوي على 12 رقماً)';
    }

    return null;
  }
}
