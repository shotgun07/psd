import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineSyncService {
  late Box _offlineDataBox;
  late Box _syncQueueBox;
  final Connectivity _connectivity = Connectivity();

  Future<void> initialize() async {
    await Hive.initFlutter();
    _offlineDataBox = await Hive.openBox('offline_data');
    _syncQueueBox = await Hive.openBox('sync_queue');
  }

  Future<void> saveTripDataOffline(Map<String, dynamic> tripData) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Save to offline storage
      await _offlineDataBox.put('trip_${DateTime.now().millisecondsSinceEpoch}', tripData);
      // Add to sync queue
      await _addToSyncQueue('trip', tripData);
    } else {
      // Sync immediately
      await _syncTripData(tripData);
    }
  }

  Future<void> saveUserDataOffline(Map<String, dynamic> userData) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      await _offlineDataBox.put('user_${DateTime.now().millisecondsSinceEpoch}', userData);
      await _addToSyncQueue('user', userData);
    } else {
      await _syncUserData(userData);
    }
  }

  Future<void> syncPendingData() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      final pendingItems = _syncQueueBox.values.toList();
      for (final item in pendingItems) {
        try {
          if (item['type'] == 'trip') {
            await _syncTripData(item['data']);
          } else if (item['type'] == 'user') {
            await _syncUserData(item['data']);
          }
          await _syncQueueBox.delete(item['id']);
        } catch (e) {
          // Log error and keep in queue
          print('Sync failed for ${item['id']}: $e');
        }
      }
    }
  }

  Future<void> _addToSyncQueue(String type, Map<String, dynamic> data) async {
    final queueItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _syncQueueBox.put(queueItem['id'], queueItem);
  }

  Future<void> _syncTripData(Map<String, dynamic> tripData) async {
    // Simulate API call to sync trip data
    // In real implementation, call your backend API
    await Future.delayed(const Duration(seconds: 1));
    print('Trip data synced: $tripData');
  }

  Future<void> _syncUserData(Map<String, dynamic> userData) async {
    // Simulate API call to sync user data
    await Future.delayed(const Duration(seconds: 1));
    print('User data synced: $userData');
  }

  List<Map<String, dynamic>> getPendingSyncItems() {
    return _syncQueueBox.values.cast<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic>? getOfflineData(String key) {
    return _offlineDataBox.get(key);
  }

  Future<void> clearOfflineData() async {
    await _offlineDataBox.clear();
    await _syncQueueBox.clear();
  }

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}