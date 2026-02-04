/// BiometricOnboardingService: AI-based identity verification for drivers.

import 'dart:convert';
import 'package:http/http.dart' as http;

class BiometricOnboardingService {
  /// Onboards a driver using biometric verification via backend API.
  Future<BiometricOnboardingResult> onboardDriver(String driverId, String biometricData) async {
    final url = Uri.parse('https://api.oblns.ai/b2b/biometric_onboarding/onboard');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'driverId': driverId,
        'biometricData': biometricData,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BiometricOnboardingResult(
        success: data['success'],
        message: data['message'],
      );
    } else {
      throw Exception('Biometric Onboarding Error: ${response.body}');
    }
  }
}

class BiometricOnboardingResult {
  final bool success;
  final String message;
  BiometricOnboardingResult({required this.success, required this.message});
}
