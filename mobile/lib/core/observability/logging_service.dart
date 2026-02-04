import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      // Sentry.captureMessage(message, level: SentryLevel.info);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      // Sentry.captureMessage(message, level: SentryLevel.warning);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    if (!kDebugMode) {
      // Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
}
