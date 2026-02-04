/// PayoutsService: Real-time payouts for captains (drivers/couriers).

import 'dart:convert';
import 'package:http/http.dart' as http;

class PayoutsService {
  /// Instantly withdraws earnings for a captain using payment gateway API.
  Future<void> withdrawEarnings(String captainId, double amount) async {
    final url = Uri.parse('https://api.oblns.ai/payouts/withdraw');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'captainId': captainId, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Payouts Withdraw Error: ${response.body}');
    }
  }
}
