import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A utility class to help with testing common scenarios
class TestHelper {
  /// Creates a mock test environment
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Add setup logic here
  }

  /// Wraps a widget in a MaterialApp for testing
  static Widget createTestWidget({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Generates a large list of dummy data for performance testing
  static List<String> generateLargeData(int count) {
    return List.generate(
      count,
      (index) => 'Item $index - ${DateTime.now().toIso8601String()}',
    );
  }

  /// Simulates a network delay
  static Future<void> simulateNetworkDelay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}
