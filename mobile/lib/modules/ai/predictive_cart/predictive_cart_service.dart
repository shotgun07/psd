
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictiveCartService {
  /// Returns a list of recommended items for the user's cart using AI/ML backend.
  Future<List<CartItem>> getPredictedCart(String userId) async {
    final url = Uri.parse('https://api.oblns.ai/predictive_cart');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => CartItem(
        name: item['name'],
        quantity: item['quantity'],
        scheduledTime: item['scheduledTime'],
      )).toList();
    } else {
      throw Exception('PredictiveCart API Error: ${response.body}');
    }
  }
}

class CartItem {
  final String name;
  final int quantity;
  final String? scheduledTime;
  CartItem({required this.name, required this.quantity, this.scheduledTime});
}
