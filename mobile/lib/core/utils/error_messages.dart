/// مركز رسائل الأخطاء - تحويل جميع الاستثناءات إلى رسائل عربية واضحة
/// Centralized error message mapping for user-friendly Arabic error messages
class ErrorMessages {
  /// الحصول على رسالة خطأ عربية من أي استثناء
  static String getArabicMessage(dynamic error) {
    if (error == null) return 'حدث خطأ غير معروف';

    final errorString = error.toString().toLowerCase();

    // شبكة واتصال - Network & Connection
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'مشكلة في الاتصال. يرجى التحقق من الإنترنت';
    }

    // انتهاء المهلة - Timeout
    if (errorString.contains('timeout') || errorString.contains('deadline')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    }

    // محاولات كثيرة - Rate Limiting
    if (errorString.contains('too many') ||
        errorString.contains('rate limit') ||
        errorString.contains('quota exceeded')) {
      return 'عدد المحاولات كبير جداً. يرجى الانتظار قليلاً';
    }

    // بيانات غير صحيحة - Invalid Data
    if (errorString.contains('invalid') ||
        errorString.contains('incorrect') ||
        errorString.contains('wrong')) {
      return 'البيانات المدخلة غير صحيحة';
    }

    // غير مصرح - Unauthorized
    if (errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated') ||
        errorString.contains('401')) {
      return 'يجب تسجيل الدخول للمتابعة';
    }

    // ممنوع - Forbidden
    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }

    // غير موجود - Not Found
    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'البيانات المطلوبة غير موجودة';
    }

    // تعارض - Conflict
    if (errorString.contains('conflict') ||
        errorString.contains('already exists') ||
        errorString.contains('409')) {
      return 'البيانات موجودة مسبقاً';
    }

    // خطأ في الخادم - Server Error
    if (errorString.contains('500') ||
        errorString.contains('internal server') ||
        errorString.contains('server error')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    }

    // خدمة غير متاحة - Service Unavailable
    if (errorString.contains('503') ||
        errorString.contains('service unavailable') ||
        errorString.contains('maintenance')) {
      return 'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً';
    }

    // Appwrite specific errors
    if (errorString.contains('appwrite')) {
      return mapAppwriteError(errorString);
    }

    // Firebase specific errors
    if (errorString.contains('firebase')) {
      return mapFirebaseError(errorString);
    }

    // رسالة افتراضية - Default message
    return error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '');
  }

  /// تحويل أخطاء Appwrite إلى رسائل عربية
  static String mapAppwriteError(String error) {
    final errorLower = error.toLowerCase();

    // Authentication errors
    if (errorLower.contains('user_unauthorized')) {
      return 'يجب تسجيل الدخول للمتابعة';
    }
    if (errorLower.contains('user_blocked')) {
      return 'تم حظر حسابك. يرجى التواصل مع الدعم';
    }
    if (errorLower.contains('user_invalid_token')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
    }
    if (errorLower.contains('user_session_not_found')) {
      return 'الجلسة غير موجودة. يرجى تسجيل الدخول';
    }
    if (errorLower.contains('user_phone_already_exists')) {
      return 'رقم الهاتف مسجل مسبقاً';
    }
    if (errorLower.contains('user_email_already_exists')) {
      return 'البريد الإلكتروني مسجل مسبقاً';
    }
    if (errorLower.contains('user_invalid_credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (errorLower.contains('user_phone_not_found')) {
      return 'رقم الهاتف غير مسجل';
    }

    // OTP errors
    if (errorLower.contains('user_invalid_token') ||
        errorLower.contains('invalid_otp')) {
      return 'رمز التحقق غير صحيح';
    }
    if (errorLower.contains('user_token_expired') ||
        errorLower.contains('otp_expired')) {
      return 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد';
    }

    // Document/Collection errors
    if (errorLower.contains('document_not_found')) {
      return 'البيانات المطلوبة غير موجودة';
    }
    if (errorLower.contains('collection_not_found')) {
      return 'قاعدة البيانات غير متاحة';
    }
    if (errorLower.contains('document_already_exists')) {
      return 'البيانات موجودة مسبقاً';
    }
    if (errorLower.contains('document_invalid_structure')) {
      return 'بنية البيانات غير صحيحة';
    }

    // Storage errors
    if (errorLower.contains('storage_file_not_found')) {
      return 'الملف غير موجود';
    }
    if (errorLower.contains('storage_invalid_file_size')) {
      return 'حجم الملف غير مسموح';
    }
    if (errorLower.contains('storage_invalid_file_type')) {
      return 'نوع الملف غير مسموح';
    }
    if (errorLower.contains('storage_device_not_found')) {
      return 'مساحة التخزين غير متاحة';
    }

    // Function errors
    if (errorLower.contains('function_not_found')) {
      return 'الوظيفة المطلوبة غير متاحة';
    }
    if (errorLower.contains('function_runtime_error')) {
      return 'خطأ في تنفيذ العملية';
    }
    if (errorLower.contains('function_timeout')) {
      return 'انتهت مهلة تنفيذ العملية';
    }

    // General errors
    if (errorLower.contains('general_rate_limit_exceeded')) {
      return 'عدد المحاولات كبير جداً. يرجى الانتظار قليلاً';
    }
    if (errorLower.contains('general_unknown')) {
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }

    return 'حدث خطأ في النظام. يرجى المحاولة لاحقاً';
  }

  /// تحويل أخطاء Firebase إلى رسائل عربية
  static String mapFirebaseError(String error) {
    final errorLower = error.toLowerCase();

    // Authentication errors
    if (errorLower.contains('user-not-found')) {
      return 'المستخدم غير موجود';
    }
    if (errorLower.contains('wrong-password')) {
      return 'كلمة المرور غير صحيحة';
    }
    if (errorLower.contains('invalid-email')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    if (errorLower.contains('email-already-in-use')) {
      return 'البريد الإلكتروني مسجل مسبقاً';
    }
    if (errorLower.contains('weak-password')) {
      return 'كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى';
    }
    if (errorLower.contains('operation-not-allowed')) {
      return 'العملية غير مسموحة';
    }
    if (errorLower.contains('account-exists-with-different-credential')) {
      return 'الحساب موجود بطريقة تسجيل دخول مختلفة';
    }
    if (errorLower.contains('invalid-credential')) {
      return 'بيانات الاعتماد غير صحيحة';
    }
    if (errorLower.contains('user-disabled')) {
      return 'تم تعطيل حسابك. يرجى التواصل مع الدعم';
    }
    if (errorLower.contains('too-many-requests')) {
      return 'عدد المحاولات كبير جداً. يرجى المحاولة لاحقاً';
    }

    // Phone Authentication errors
    if (errorLower.contains('invalid-phone-number')) {
      return 'رقم الهاتف غير صحيح';
    }
    if (errorLower.contains('invalid-verification-code')) {
      return 'رمز التحقق غير صحيح';
    }
    if (errorLower.contains('invalid-verification-id')) {
      return 'معرف التحقق غير صحيح';
    }
    if (errorLower.contains('session-expired')) {
      return 'انتهت صلاحية الجلسة';
    }
    if (errorLower.contains('quota-exceeded')) {
      return 'تم تجاوز الحد المسموح';
    }

    // Firestore errors
    if (errorLower.contains('permission-denied')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }
    if (errorLower.contains('not-found')) {
      return 'البيانات غير موجودة';
    }
    if (errorLower.contains('already-exists')) {
      return 'البيانات موجودة مسبقاً';
    }
    if (errorLower.contains('failed-precondition')) {
      return 'الشروط المسبقة غير متوفرة';
    }
    if (errorLower.contains('aborted')) {
      return 'تم إلغاء العملية';
    }
    if (errorLower.contains('out-of-range')) {
      return 'البيانات خارج النطاق المسموح';
    }
    if (errorLower.contains('unimplemented')) {
      return 'الميزة غير متاحة حالياً';
    }
    if (errorLower.contains('unavailable')) {
      return 'الخدمة غير متاحة. يرجى المحاولة لاحقاً';
    }
    if (errorLower.contains('data-loss')) {
      return 'حدث فقدان في البيانات';
    }

    // Storage errors
    if (errorLower.contains('object-not-found')) {
      return 'الملف غير موجود';
    }
    if (errorLower.contains('bucket-not-found')) {
      return 'مساحة التخزين غير موجودة';
    }
    if (errorLower.contains('project-not-found')) {
      return 'المشروع غير موجود';
    }
    if (errorLower.contains('quota-exceeded')) {
      return 'تم تجاوز مساحة التخزين المسموحة';
    }
    if (errorLower.contains('unauthenticated')) {
      return 'يجب تسجيل الدخول';
    }
    if (errorLower.contains('unauthorized')) {
      return 'ليس لديك صلاحية للوصول';
    }
    if (errorLower.contains('retry-limit-exceeded')) {
      return 'تم تجاوز عدد المحاولات المسموحة';
    }
    if (errorLower.contains('invalid-checksum')) {
      return 'الملف تالف. يرجى المحاولة مرة أخرى';
    }
    if (errorLower.contains('canceled')) {
      return 'تم إلغاء العملية';
    }

    // Network errors
    if (errorLower.contains('network-request-failed')) {
      return 'فشل الاتصال بالشبكة';
    }

    return 'حدث خطأ في Firebase. يرجى المحاولة لاحقاً';
  }

  /// تحويل أخطاء الدفع إلى رسائل عربية
  static String mapPaymentError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('insufficient_funds')) {
      return 'الرصيد غير كافي';
    }
    if (errorLower.contains('card_declined')) {
      return 'تم رفض البطاقة';
    }
    if (errorLower.contains('expired_card')) {
      return 'البطاقة منتهية الصلاحية';
    }
    if (errorLower.contains('invalid_card')) {
      return 'بيانات البطاقة غير صحيحة';
    }
    if (errorLower.contains('payment_failed')) {
      return 'فشلت عملية الدفع';
    }
    if (errorLower.contains('transaction_timeout')) {
      return 'انتهت مهلة المعاملة';
    }

    return 'حدث خطأ في عملية الدفع';
  }

  /// تحويل أخطاء التحقق من النماذج إلى رسائل عربية
  static String mapValidationError(String field, String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('required')) {
      return 'هذا الحقل مطلوب';
    }
    if (errorLower.contains('invalid_email')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    if (errorLower.contains('invalid_phone')) {
      return 'رقم الهاتف غير صحيح';
    }
    if (errorLower.contains('min_length')) {
      return 'الحد الأدنى للأحرف غير مستوفى';
    }
    if (errorLower.contains('max_length')) {
      return 'تم تجاوز الحد الأقصى للأحرف';
    }
    if (errorLower.contains('invalid_format')) {
      return 'التنسيق غير صحيح';
    }

    return 'قيمة غير صحيحة';
  }
}
