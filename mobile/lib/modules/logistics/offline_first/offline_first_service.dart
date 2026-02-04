/// OfflineFirstService: Handles offline-first transaction protocol (SMS/USSD fallback).

import 'dart:convert';
import 'package:http/http.dart' as http;

class OfflineFirstService {
  /// Places an order using offline protocol (SMS/USSD) via backend API.
  Future<OfflineOrderResponse> placeOrderOffline(String userId, List<BasketItem> items) async {
    final url = Uri.parse('https://api.oblns.ai/offline_first/order');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'items': items.map((e) => {
          'storeId': e.storeId,
          'itemId': e.itemId,
          'quantity': e.quantity,
        }).toList(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return OfflineOrderResponse(
        orderId: data['orderId'],
        status: data['status'],
        fallbackMethod: data['fallbackMethod'],
      );
    } else {
      throw Exception('Offline Order Error: ${response.body}');
    }
  }
}

class BasketItem {
  String storeId;
  String itemId;
  int quantity;
  BasketItem({required this.storeId, required this.itemId, required this.quantity});
}

class OfflineOrderResponse {
  final String orderId;
  final String status;
  final String fallbackMethod;
  OfflineOrderResponse({required this.orderId, required this.status, required this.fallbackMethod});
}
