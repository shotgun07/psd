/// UtilityBillsService: Pay utility bills using vault credits.

import 'dart:convert';
import 'package:http/http.dart' as http;

class UtilityBillsService {
  /// Pays a utility bill for the user using national infrastructure API.
  Future<void> payBill(String userId, String billType, double amount) async {
    final url = Uri.parse('https://api.oblns.ai/utility_bills/pay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'billType': billType, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('UtilityBills Pay Error: ${response.body}');
    }
  }
}
