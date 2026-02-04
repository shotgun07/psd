import 'package:latlong2/latlong.dart';
import 'dart:async';

/// OfflineOrderService
/// Handles "Extreme Offline Lifecycle" requirements.
/// Logs GPS path locally and syncs with server upon reconnection.
class OfflineOrderService {
  final List<LatLng> _localPathQueue = [];
  bool _isOffline = false;

  void onConnectionChanged(bool isConnected) {
    _isOffline = !isConnected;
    if (isConnected && _localPathQueue.isNotEmpty) {
      _syncPathWithServer();
    }
  }

  void logCoordinate(LatLng point) {
    if (_isOffline) {
      _localPathQueue.add(point);
      // In real implementation: Save to sqflite/Hive
    }
  }

  Future<void> _syncPathWithServer() async {
    // 1. Send batched GPS points to backend
    // 2. Clear local queue
    _localPathQueue.clear();
  }

  /// Calculates final distance even if offline
  double calculateOfflineDistance() {
    double total = 0;
    for (int i = 0; i < _localPathQueue.length - 1; i++) {
      total += _calculateDistance(_localPathQueue[i], _localPathQueue[i + 1]);
    }
    return total;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    // Simple Haversine logic
    return 0.1; // Stub
  }
}
