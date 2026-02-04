import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/driver_model.dart';
import 'package:oblns/core/firebase_config.dart';

class FirebaseDriverRepository {
  final FirebaseFirestore _firestore;

  FirebaseDriverRepository(this._firestore);

  Future<void> saveDriverProfile(DriverModel driver) async {
    try {
      await _firestore
          .collection(FirebaseConfig.driversCollection)
          .doc(driver.id)
          .set({
        'user_id': driver.userId,
        'is_online': driver.isOnline,
        'rating': driver.rating,
        'vehicle_type': driver.vehicleType,
        'vehicle_plate': driver.vehiclePlate,
        'vehicle_details': driver.vehicleDetails,
        'verification_status': driver.verificationStatus,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('فشل حفظ بيانات السائق: $e');
    }
  }

  Future<DriverModel?> getDriverProfile(String driverId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.driversCollection)
          .doc(driverId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return DriverModel(
        id: doc.id,
        userId: data['user_id'] ?? '',
        isOnline: data['is_online'] ?? false,
        rating: (data['rating'] ?? 5.0).toDouble(),
        vehicleType: data['vehicle_type'],
        vehiclePlate: data['vehicle_plate'],
        vehicleDetails: data['vehicle_details'],
        verificationStatus: data['verification_status'] ?? 'pending',
      );
    } catch (e) {
      return null;
    }
  }

  Stream<DriverModel?> getDriverStream(String userId) {
    return _firestore
        .collection(FirebaseConfig.driversCollection)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return DriverModel(
        id: doc.id,
        userId: data['user_id'] ?? '',
        isOnline: data['is_online'] ?? false,
        rating: (data['rating'] ?? 5.0).toDouble(),
        vehicleType: data['vehicle_type'],
        vehiclePlate: data['vehicle_plate'],
        vehicleDetails: data['vehicle_details'],
        verificationStatus: data['verification_status'] ?? 'pending',
      );
    });
  }

  Future<void> toggleOnlineStatus(String driverId, bool status) async {
    await _firestore
        .collection(FirebaseConfig.driversCollection)
        .doc(driverId)
        .update({
      'is_online': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVehicle({
    required String driverId,
    required String type,
    required String plate,
    String? details,
  }) async {
    await _firestore
        .collection(FirebaseConfig.driversCollection)
        .doc(driverId)
        .update({
      'vehicle_type': type,
      'vehicle_plate': plate,
      'vehicle_details': details,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitKYC(String driverId, Map<String, dynamic> kycData) async {
    await _firestore
        .collection(FirebaseConfig.driversCollection)
        .doc(driverId)
        .update({
      'kyc_data': kycData,
      'verification_status': 'pending',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}

final firebaseDriverRepositoryProvider = Provider<FirebaseDriverRepository>((
  ref,
) {
  return FirebaseDriverRepository(ref.watch(firestoreProvider));
});
