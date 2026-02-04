import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/trip_model.dart';
import 'package:oblns/core/firebase_config.dart';

class FirebaseTripRepository {
  final FirebaseFirestore _firestore;

  FirebaseTripRepository(this._firestore);

  /// Create a new trip
  Future<String> createTrip({
    required String riderId,
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    String? pickupAddress,
    String? destAddress,
  }) async {
    try {
      final tripRef = await _firestore
          .collection(FirebaseConfig.tripsCollection)
          .add({
            'rider_id': riderId,
            'driver_id': null,
            'status': 'searching',
            'pickup_location': GeoPoint(pickupLat, pickupLng),
            'pickup_address': pickupAddress ?? '',
            'destination_location': GeoPoint(destLat, destLng),
            'destination_address': destAddress ?? '',
            'fare': null,
            'distance_km': null,
            'duration_min': null,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      return tripRef.id;
    } catch (e) {
      throw Exception('فشل إنشاء الرحلة: $e');
    }
  }

  /// Get trip by ID
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.tripsCollection)
          .doc(tripId)
          .get();

      if (!doc.exists) return null;

      return _tripFromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Get trip stream
  Stream<TripModel?> getTripStream(String tripId) {
    return _firestore
        .collection(FirebaseConfig.tripsCollection)
        .doc(tripId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return _tripFromFirestore(doc);
        });
  }

  /// Get user trips
  Stream<List<TripModel>> getUserTrips(String userId) {
    return _firestore
        .collection(FirebaseConfig.tripsCollection)
        .where('rider_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _tripFromFirestore(doc)).toList();
        });
  }

  /// Get driver trips
  Stream<List<TripModel>> getDriverTrips(String driverId) {
    return _firestore
        .collection(FirebaseConfig.tripsCollection)
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _tripFromFirestore(doc)).toList();
        });
  }

  /// Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    await _firestore
        .collection(FirebaseConfig.tripsCollection)
        .doc(tripId)
        .update({'status': status, 'updated_at': FieldValue.serverTimestamp()});
  }

  /// Assign driver to trip
  Future<void> assignDriver(String tripId, String driverId) async {
    await _firestore
        .collection(FirebaseConfig.tripsCollection)
        .doc(tripId)
        .update({
          'driver_id': driverId,
          'status': 'assigned',
          'updated_at': FieldValue.serverTimestamp(),
        });
  }

  /// Complete trip
  Future<void> completeTrip({
    required String tripId,
    required double fare,
    required double distanceKm,
    required int durationMin,
  }) async {
    await _firestore
        .collection(FirebaseConfig.tripsCollection)
        .doc(tripId)
        .update({
          'status': 'completed',
          'fare': fare,
          'distance_km': distanceKm,
          'duration_min': durationMin,
          'completed_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
  }

  /// Cancel trip
  Future<void> cancelTrip(String tripId, String reason) async {
    await _firestore
        .collection(FirebaseConfig.tripsCollection)
        .doc(tripId)
        .update({
          'status': 'cancelled',
          'cancellation_reason': reason,
          'updated_at': FieldValue.serverTimestamp(),
        });
  }

  /// Get active trip for rider
  Future<TripModel?> getActiveTrip(String riderId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.tripsCollection)
          .where('rider_id', isEqualTo: riderId)
          .where('status', whereIn: ['searching', 'assigned', 'active'])
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return _tripFromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// Get active trip for driver
  Future<TripModel?> getActiveDriverTrip(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.tripsCollection)
          .where('driver_id', isEqualTo: driverId)
          .where('status', whereIn: ['assigned', 'active'])
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return _tripFromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// Helper method to convert Firestore document to TripModel
  TripModel _tripFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pickupLocation = data['pickup_location'] as GeoPoint;
    final destLocation = data['destination_location'] as GeoPoint;

    return TripModel(
      id: doc.id,
      riderId: data['rider_id'] ?? '',
      driverId: data['driver_id'],
      status: data['status'] ?? 'searching',
      originLat: pickupLocation.latitude,
      originLng: pickupLocation.longitude,
      destLat: destLocation.latitude,
      destLng: destLocation.longitude,
      fare: data['fare']?.toDouble(),
      geohash: data['geohash'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}

final firebaseTripRepositoryProvider = Provider<FirebaseTripRepository>((ref) {
  return FirebaseTripRepository(ref.watch(firestoreProvider));
});
