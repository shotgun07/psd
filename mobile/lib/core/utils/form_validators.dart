/// أدوات التحقق من صحة النماذج - Form Validation Utilities
/// مجموعة شاملة من أدوات التحقق من المدخلات
class FormValidators {
  /// تحقق من رقم الهاتف - Validate phone number
  /// يدعم الأرقام الليبية (+218) والصيغ المختلفة
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // إزالة المسافات والشرطات
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    // تحقق من الصيغة الليبية
    // +218XXXXXXXXX أو 00218XXXXXXXXX أو 0XXXXXXXXX
    final libyaRegex = RegExp(r'^(\+218|00218|0)(91|92|93|94|95)\d{7}$');

    if (!libyaRegex.hasMatch(cleaned)) {
      return 'رقم الهاتف غير صحيح. استخدم صيغة: 091XXXXXXX';
    }

    return null;
  }

  /// تحقق من البريد الإلكتروني - Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// تحقق من المبلغ المالي - Validate amount
  static String? validateAmount(
    String? value, {
    double? minAmount,
    double? maxAmount,
  }) {
    if (value == null || value.isEmpty) {
      return 'المبلغ مطلوب';
    }

    final amount = double.tryParse(value);

    if (amount == null) {
      return 'المبلغ غير صحيح';
    }

    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }

    if (minAmount != null && amount < minAmount) {
      return 'الحد الأدنى للمبلغ هو $minAmount دينار';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'الحد الأقصى للمبلغ هو $maxAmount دينار';
    }

    return null;
  }

  /// تحقق من الحقل المطلوب - Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// تحقق من الحد الأدنى للطول - Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }

    if (value.length < minLength) {
      return 'الحد الأدنى $minLength أحرف';
    }

    return null;
  }

  /// تحقق من الحد الأقصى للطول - Validate maximum length
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return null; // إذا كان الحقل فارغاً، لا تحقق من الطول
    }

    if (value.length > maxLength) {
      return 'الحد الأقصى $maxLength حرف';
    }

    return null;
  }

  /// تحقق من كلمة المرور - Validate password
  static String? validatePassword(String? value, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (requireStrong) {
      // تحقق من قوة كلمة المرور
      final hasUppercase = value.contains(RegExp(r'[A-Z]'));
      final hasLowercase = value.contains(RegExp(r'[a-z]'));
      final hasDigits = value.contains(RegExp(r'[0-9]'));
      final hasSpecialCharacters = value.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );

      if (!hasUppercase) {
        return 'كلمة المرور يجب أن تحتوي على حرف كبير';
      }
      if (!hasLowercase) {
        return 'كلمة المرور يجب أن تحتوي على حرف صغير';
      }
      if (!hasDigits) {
        return 'كلمة المرور يجب أن تحتوي على رقم';
      }
      if (!hasSpecialCharacters) {
        return 'كلمة المرور يجب أن تحتوي على رمز خاص';
      }
    }

    return null;
  }

  /// تحقق من تطابق كلمات المرور - Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  /// تحقق من رمز OTP - Validate OTP code
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }

    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// تحقق من رقم الهوية - Validate national ID
  static String? validateNationalID(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهوية مطلوب';
    }

    // رقم الهوية الليبي: 12 رقم
    if (value.length != 12) {
      return 'رقم الهوية يجب أن يكون 12 رقم';
    }

    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return 'رقم الهوية يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  /// تحقق من تاريخ الميلاد - Validate date of birth
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'تاريخ الميلاد مطلوب';
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (age < 18) {
      return 'يجب أن يكون عمرك 18 سنة على الأقل';
    }

    if (age > 120) {
      return 'تاريخ الميلاد غير صحيح';
    }

    return null;
  }

  /// تحقق من عنوان URL - Validate URL
  static String? validateURL(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'الرابط مطلوب' : null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  /// حساب قوة كلمة المرور - Calculate password strength
  /// يعيد قيمة من 0.0 (ضعيفة) إلى 1.0 (قوية جداً)
  static double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // الطول
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.1;

    // أحرف كبيرة
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;

    // أحرف صغيرة
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;

    // أرقام
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;

    // رموز خاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  /// الحصول على وصف لقوة كلمة المرور - Get password strength description
  static String getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'ضعيفة';
    if (strength < 0.5) return 'متوسطة';
    if (strength < 0.7) return 'جيدة';
    if (strength < 0.9) return 'قوية';
    return 'قوية جداً';
  }
}
