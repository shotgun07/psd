import 'dart:async';
import 'package:flutter/foundation.dart';

/// أداة Debouncer لتأخير تنفيذ العمليات
/// Debouncer utility to delay operation execution and prevent rapid repeated calls
///
/// مفيد للغاية في:
/// - منع النقر المتكرر على الأزرار (Double-click prevention)
/// - تأخير البحث أثناء الكتابة (Search as you type)
/// - تحسين الأداء بتقليل العمليات المتكررة
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// تشغيل العملية بعد فترة التأخير
  /// Run the action after the delay period
  void run(VoidCallback action) {
    // إلغاء المؤقت السابق إن وجد
    _timer?.cancel();

    // إنشاء مؤقت جديد
    _timer = Timer(delay, action);
  }

  /// إلغاء العملية المعلقة
  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// التحقق من وجود عملية معلقة
  /// Check if there's a pending action
  bool get isActive => _timer?.isActive ?? false;

  /// تنظيف الموارد
  /// Cleanup resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// أداة Throttler لتحديد معدل تنفيذ العمليات
/// Throttler utility to limit the rate of operation execution
///
/// الفرق بين Debouncer و Throttler:
/// - Debouncer: ينتظر حتى توقف الأحداث ثم ينفذ
/// - Throttler: ينفذ العملية بحد أقصى مرة واحدة كل فترة زمنية محددة
class Throttler {
  final Duration delay;
  bool _isThrottled = false;
  Timer? _timer;

  Throttler({required this.delay});

  /// تشغيل العملية إذا سمحت الفترة الزمنية
  /// Run the action if the time period allows
  void run(VoidCallback action) {
    if (_isThrottled) return;

    // تنفيذ العملية فوراً
    action();

    // منع العمليات الجديدة لفترة محددة
    _isThrottled = true;
    _timer = Timer(delay, () {
      _isThrottled = false;
    });
  }

  /// إلغاء الحظر والسماح بعمليات جديدة
  /// Cancel throttling and allow new actions
  void reset() {
    _timer?.cancel();
    _isThrottled = false;
  }

  /// التحقق من الحالة
  /// Check status
  bool get isThrottled => _isThrottled;

  /// تنظيف الموارد
  /// Cleanup resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// أداة AsyncDebouncer للعمليات غير المتزامنة
/// AsyncDebouncer for asynchronous operations
class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;

  AsyncDebouncer({required this.delay});

  /// تشغيل عملية غير متزامنة بعد فترة التأخير
  /// Run an async action after the delay period
  Future<void> run(Future<void> Function() action) async {
    _timer?.cancel();

    final completer = Completer<void>();

    _timer = Timer(delay, () async {
      try {
        await action();
        completer.complete();
      } catch (error) {
        completer.completeError(error);
      }
    });

    return completer.future;
  }

  /// إلغاء العملية المعلقة
  void cancel() {
    _timer?.cancel();
  }

  /// تنظيف الموارد
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Extension لتسهيل استخدام Debouncer
extension DebouncerExtension on VoidCallback {
  /// تحويل دالة إلى دالة مع debounce
  /// Convert a function to a debounced function
  VoidCallback debounce(Duration delay) {
    final debouncer = Debouncer(delay: delay);
    return () => debouncer.run(this);
  }
}

/// Extension لتسهيل استخدام Throttler
extension ThrottlerExtension on VoidCallback {
  /// تحويل دالة إلى دالة مع throttle
  /// Convert a function to a throttled function
  VoidCallback throttle(Duration delay) {
    final throttler = Throttler(delay: delay);
    return () => throttler.run(this);
  }
}
