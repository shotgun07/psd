/// BNPLService: Buy Now, Pay Later for essentials.

import 'dart:convert';
import 'package:http/http.dart' as http;

class BNPLService {
  /// Checks if user is eligible for BNPL using credit scoring API.
  Future<bool> isEligible(String userId) async {
    final url = Uri.parse('https://api.oblns.ai/bnpl/eligibility');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['eligible'] == true;
    } else {
      throw Exception('BNPL Eligibility Error: ${response.body}');
    }
  }

  /// Creates a BNPL order for the user using payment backend.
  Future<void> createBnplOrder(String userId, double amount) async {
    final url = Uri.parse('https://api.oblns.ai/bnpl/order');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('BNPL Order Error: ${response.body}');
    }
  }
}
