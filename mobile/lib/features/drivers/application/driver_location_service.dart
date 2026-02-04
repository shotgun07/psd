import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:oblns/core/appwrite_config.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';
import 'package:oblns/core/observability/logging_config.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';

class DriverLocationService {
  final Databases _databases;
  final Realtime _realtime;
  final GeoHasher _geoHasher = GeoHasher();

  Timer? _locationUpdateTimer;
  String? _currentDriverId;

  DriverLocationService(this._databases, this._realtime);

  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  /// Start tracking driver location
  Future<void> startTracking(String driverId) async {
    _currentDriverId = driverId;

    // Update location every 15 seconds
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateLocation(driverId),
    );

    // Initial update
    await _updateLocation(driverId);
  }

  /// Stop tracking driver location
  Future<void> stopTracking() async {
    _locationUpdateTimer?.cancel();

    if (_currentDriverId != null) {
      try {
        await _dbWrapper.updateDocument(
          databaseId: AppwriteConfig.dbId,
          collectionId: AppwriteConfig.driversCollectionId,
          documentId: _currentDriverId!,
          data: {
            'is_online': false,
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        AppLogger.error('Error stopping tracking', e);
      }
    }

    _currentDriverId = null;
  }

  /// Update driver location
  Future<void> _updateLocation(String driverId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
        ),
      );

      final geohash = _geoHasher.encode(
        position.longitude,
        position.latitude,
        precision: 7,
      );

      await _dbWrapper.updateDocument(
        databaseId: AppwriteConfig.dbId,
        collectionId: AppwriteConfig.driversCollectionId,
        documentId: driverId,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'geohash': geohash,
          'is_online': true,
          'heading': position.heading,
          'speed': position.speed,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      AppLogger.error('Error updating location', e);
    }
  }

  /// Get nearby drivers
  Future<List<DriverLocation>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusInKm = 10.0,
  }) async {
    try {
      // In Appwrite, we can use queries. For MVP, query by is_online=true and client-side filter
      // Production usage should use geohash queries if supported or a Function
      final response = await _dbWrapper.listDocuments(
        databaseId: AppwriteConfig.dbId,
        collectionId: AppwriteConfig.driversCollectionId,
        queries: [
          Query.equal('is_online', true),
          Query.limit(50), // Limit to avoid fetch all
        ],
      );

      final drivers = <DriverLocation>[];

      for (var doc in response.documents) {
        final driverLat = (doc.data['latitude'] as num).toDouble();
        final driverLng = (doc.data['longitude'] as num).toDouble();

        final distance =
            Geolocator.distanceBetween(
              latitude,
              longitude,
              driverLat,
              driverLng,
            ) /
            1000;

        if (distance <= radiusInKm) {
          drivers.add(
            DriverLocation(
              driverId: doc.$id,
              latitude: driverLat,
              longitude: driverLng,
              geohash: doc.data['geohash'] ?? '',
              isOnline: true,
              distance: distance,
              heading: (doc.data['heading'] as num?)?.toDouble(),
              speed: (doc.data['speed'] as num?)?.toDouble(),
              updatedAt: DateTime.parse(doc.data['updated_at']),
            ),
          );
        }
      }

      drivers.sort((a, b) => a.distance.compareTo(b.distance));
      return drivers;
    } catch (e) {
      AppLogger.error('Error getting nearby drivers', e);
      return [];
    }
  }

  /// Watch specific driver location
  Stream<DriverLocation?> watchDriverLocation(String driverId) {
    final subscription = _realtime.subscribe([
      'databases.${AppwriteConfig.dbId}.collections.${AppwriteConfig.driversCollectionId}.documents.$driverId',
    ]);

    return subscription.stream.map((event) {
      if (event.payload.isEmpty) return null;

      final data = event.payload;
      return DriverLocation(
        driverId: driverId,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        geohash: data['geohash'] ?? '',
        isOnline: data['is_online'] ?? false,
        distance: 0,
        heading: (data['heading'] as num?)?.toDouble(),
        speed: (data['speed'] as num?)?.toDouble(),
        updatedAt: DateTime.parse(data['updated_at']),
      );
    });
  }
}

class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final String geohash;
  final bool isOnline;
  final double distance;
  final double? heading;
  final double? speed;
  final DateTime updatedAt;

  DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.isOnline,
    required this.distance,
    this.heading,
    this.speed,
    required this.updatedAt,
  });
}

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  return DriverLocationService(
    ref.watch(appwriteDatabasesProvider),
    ref.watch(appwriteRealtimeProvider),
  );
});
