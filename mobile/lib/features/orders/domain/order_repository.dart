import 'package:oblns/core/models/trip_model.dart';

abstract class OrderRepository {
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
  });
  Future<TripModel> getOrder(String orderId);
  Future<void> cancelOrder(String orderId);
  Stream<TripModel> watchOrder(String orderId);
  Future<void> rateTrip(String orderId, int rating, String? comment);
}
