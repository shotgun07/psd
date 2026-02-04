import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConsentType { location, audio, dataSharing, marketing }

class ConsentRecordingService {
  static const String _consentPrefix = 'user_consent_';

  Future<void> recordConsent(ConsentType type, bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();

    await prefs.setString(
      '$_consentPrefix${type.name}',
      '$allowed|$timestamp',
    );
  }

  Future<bool> hasConsent(ConsentType type) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('$_consentPrefix${type.name}');
    if (value == null) return false;

    return value.split('|').first == 'true';
  }
}

final consentServiceProvider = Provider<ConsentRecordingService>((ref) {
  return ConsentRecordingService();
});