import 'package:appwrite/appwrite.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';
import 'package:oblns/core/models/trip_model.dart';
import 'package:oblns/features/orders/domain/order_repository.dart';
import 'package:oblns/core/appwrite_config.dart';

class AppwriteOrderRepository implements OrderRepository {
  final Databases _databases;
  final Realtime _realtime;
  final Functions _functions;

  AppwriteOrderRepository(this._databases, this._realtime, this._functions);

  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  @override
  Future<String> createOrder({
    required String type,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    final document = await _dbWrapper.createDocument(
      databaseId: AppwriteConfig.dbId,
      collectionId: AppwriteConfig.tripsCollectionId,
      documentId: ID.unique(),
      data: {
        'customer_id': 'current_user_id', // Handle real user ID in production
        'type': type,
        'status': 'pending',
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_address': pickupAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'dropoff_address': dropoffAddress,
        'total_price': totalPrice,
        'payment_method': paymentMethod,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // Trigger dispatch
    try {
      await _functions.createExecution(
        functionId: AppwriteConfig.dispatchFunctionId,
        body: '{"action": "dispatch", "order_id": "${document.$id}"}',
      );
    } catch (_) {
      // Log error in production
    }

    return document.$id;
  }

  @override
  Future<TripModel> getOrder(String orderId) async {
    final document = await _dbWrapper.getDocument(
      databaseId: AppwriteConfig.dbId,
      collectionId: AppwriteConfig.tripsCollectionId,
      documentId: orderId,
    );
    return TripModel.fromJson(document.data);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _dbWrapper.updateDocument(
      databaseId: AppwriteConfig.dbId,
      collectionId: AppwriteConfig.tripsCollectionId,
      documentId: orderId,
      data: {'status': 'cancelled'},
    );
  }

  @override
  Future<void> rateTrip(String orderId, int rating, String? comment) async {
    final data = <String, dynamic>{
      'rating': rating,
      'rating_comment': comment,
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    };

    await _dbWrapper.updateDocument(
      databaseId: AppwriteConfig.dbId,
      collectionId: AppwriteConfig.tripsCollectionId,
      documentId: orderId,
      data: data,
    );
  }

  @override
  Stream<TripModel> watchOrder(String orderId) {
    final subscription = _realtime.subscribe([
      'databases.${AppwriteConfig.dbId}.collections.${AppwriteConfig.tripsCollectionId}.documents.$orderId',
    ]);

    return subscription.stream.map(
      (event) => TripModel.fromJson(event.payload),
    );
  }
}
