/// MultiBasketService: Handles universal multi-basket checkout for items from multiple stores.

import 'dart:convert';
import 'package:http/http.dart' as http;

class MultiBasketService {
  /// Combines items from different stores into a single checkout using backend API.
  Future<MultiBasketOrder> createMultiBasketOrder(String userId, List<BasketItem> items) async {
    final url = Uri.parse('https://api.oblns.ai/multi_basket/order');
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
      return MultiBasketOrder(orderId: data['orderId'], status: data['status']);
    } else {
      throw Exception('MultiBasket Order Error: ${response.body}');
    }
  }
}

class BasketItem {
  final String storeId;
  final String itemId;
  final int quantity;
  BasketItem({required this.storeId, required this.itemId, required this.quantity});
}

class MultiBasketOrder {
  final String orderId;
  final String status;
  MultiBasketOrder({required this.orderId, required this.status});
}
