import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigService {
  final Map<String, bool> _flags = {
    'enable_blackbox': true,
    'enable_whatsapp_bot': true,
    'maintenance_mode': false,
  };

  RemoteConfigService();

  Future<void> fetchConfig() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  bool isEnabled(String featureKey) => _flags[featureKey] ?? false;
}

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});