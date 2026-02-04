abstract class DriverRepository {
  Future<void> updateLocation(double lat, double lng);
  Future<void> setStatus(String status);
  Stream<Map<String, dynamic>> listenToPendingOrders();
  Future<void> acceptOrder(String orderId);
}
