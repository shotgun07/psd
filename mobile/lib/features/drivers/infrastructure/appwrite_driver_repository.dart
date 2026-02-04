import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';
import 'package:oblns/features/drivers/domain/driver_repository.dart';
import 'package:dart_geohash/dart_geohash.dart';

class AppwriteDriverRepository implements DriverRepository {
  final Databases _databases;
  final Realtime _realtime;
  final String _databaseId = 'oblns';
  final String _driversCollection = 'drivers';
  final String _geohashCollection = 'geohash_index';

  AppwriteDriverRepository(this._databases, this._realtime);

  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  @override
  Future<void> updateLocation(double lat, double lng) async {
    final geohasher = GeoHasher();
    final geohash = geohasher.encode(lng, lat, precision: 9);

    // 1. Update the geohash index for proximity search
    await _dbWrapper.updateDocument(
      databaseId: _databaseId,
      collectionId: _geohashCollection,
      documentId: 'current_driver_id', // Should be the actual driver ID
      data: {
        'driver_id': 'current_driver_id',
        'geohash': geohash,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );

    // 2. Update driver's last known position
    await _dbWrapper.updateDocument(
      databaseId: _databaseId,
      collectionId: _driversCollection,
      documentId: 'current_driver_id',
      data: {'current_lat': lat, 'current_lng': lng},
    );
  }

  @override
  Future<void> setStatus(String status) async {
    await _dbWrapper.updateDocument(
      databaseId: _databaseId,
      collectionId: _driversCollection,
      documentId: 'current_driver_id',
      data: {'is_online': status == 'online'},
    );
  }

  @override
  Stream<Map<String, dynamic>> listenToPendingOrders() {
    final subscription = _realtime.subscribe([
      'databases.$_databaseId.collections.trips.documents',
    ]);

    return subscription.stream.map((event) {
      if (event.payload['status'] == 'searching') {
        return event.payload;
      }
      return {};
    });
  }

  @override
  Future<void> acceptOrder(String orderId) async {
    await _dbWrapper.updateDocument(
      databaseId: _databaseId,
      collectionId: 'trips',
      documentId: orderId,
      data: {
        'status': 'assigned',
        'driver_id': 'current_driver_id', // Should be actual driver ID
        'assigned_at': DateTime.now().toIso8601String(),
      },
    );
  }
}

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  return AppwriteDriverRepository(databases, realtime);
});
