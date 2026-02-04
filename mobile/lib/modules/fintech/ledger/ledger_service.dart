/// LedgerService: Unified family ledger for budgets and permissions.

import 'dart:convert';
import 'package:http/http.dart' as http;

class LedgerService {
  /// Sets a budget for a family member using API.
  Future<void> setBudget(String masterId, String memberId, double amount) async {
    final url = Uri.parse('https://api.oblns.ai/ledger/set_budget');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'masterId': masterId, 'memberId': memberId, 'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Ledger SetBudget Error: ${response.body}');
    }
  }

  /// Gets the current ledger for a family from API.
  Future<Map<String, double>> getFamilyLedger(String masterId) async {
    final url = Uri.parse('https://api.oblns.ai/ledger/family');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'masterId': masterId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } else {
      throw Exception('Ledger GetFamily Error: ${response.body}');
    }
  }
}
