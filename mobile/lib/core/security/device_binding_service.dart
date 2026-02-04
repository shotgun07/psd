import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceBindingService {
  static const String _deviceIdKey = 'device_binding_id';

  /// Gets or generates a unique stable ID for this device installation.
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  /// Verifies if the current session matches the bound device.
  /// In a real app, this would check against the backend User record.
  Future<bool> verifyDeviceBinding(String expectedDeviceId) async {
    final currentId = await getDeviceId();
    // Simulate check
    return currentId == expectedDeviceId;
  }
}

final deviceBindingServiceProvider = Provider<DeviceBindingService>((ref) {
  return DeviceBindingService();
});
