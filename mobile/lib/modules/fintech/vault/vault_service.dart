/// VaultService: Manages micro-change digital vault for users.

import 'dart:convert';
import 'package:http/http.dart' as http;

class VaultService {
  /// Converts physical cash change into digital credits using wallet API.
  Future<void> depositChange(String userId, double amount) async {
    final url = Uri.parse('https://api.oblns.ai/vault/deposit');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Vault Deposit Error: ${response.body}');
    }
  }

  /// Returns the current vault balance for a user from wallet API.
  Future<double> getVaultBalance(String userId) async {
    final url = Uri.parse('https://api.oblns.ai/vault/balance');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['balance'] as num).toDouble();
    } else {
      throw Exception('Vault Balance Error: ${response.body}');
    }
  }
}
