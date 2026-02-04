import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

class AppLogger {
  static bool _isProduction = kReleaseMode;

  static void configure({bool isProduction = false}) {
    _isProduction = isProduction;
  }

  static void debug(String message, [Object? data]) {
    _log(LogLevel.debug, message, data);
  }

  static void info(String message, [Object? data]) {
    _log(LogLevel.info, message, data);
  }

  static void warning(String message, [Object? data]) {
    _log(LogLevel.warning, message, data);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? meta]) {
    _log(LogLevel.error, message, error, stackTrace: stackTrace, meta: meta);
  }

  static void critical(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? meta]) {
    _log(LogLevel.critical, message, error, stackTrace: stackTrace, meta: meta);
  }

  static void _log(
    LogLevel level,
    String message,
    Object? data, {
    StackTrace? stackTrace,
    Map<String, dynamic>? meta,
  }) {
    if (_isProduction && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    final logMessage = StringBuffer('[$timestamp] [$levelStr] $message');

    if (data != null) {
      logMessage.write(' | Data: $data');
    }

    if (meta != null) {
      logMessage.write(' | Meta: $meta');
    }

    if (stackTrace != null) {
      logMessage.write('\nStackTrace: $stackTrace');
    }

    if (kDebugMode) {
      debugPrint(logMessage.toString());
    }
  }

  // Analytics / domain-specific helpers (no-ops that forward to _log)
  static void analytics(String event, [Map<String, dynamic>? params]) {
    _log(LogLevel.info, 'Analytics: $event', params);
  }

  static void financial(String message, Object? amount, String? currency, [Map<String, dynamic>? meta]) {
    _log(LogLevel.info, 'Financial: $message', {'amount': amount, 'currency': currency, 'meta': meta});
  }

  static void security(String message, [Object? data]) {
    _log(LogLevel.warning, 'Security: $message', data);
  }
}
