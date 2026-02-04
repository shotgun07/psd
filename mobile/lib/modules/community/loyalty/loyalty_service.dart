/// LoyaltyService: Manages gamified loyalty tiers and rewards.

import 'dart:convert';
import 'package:http/http.dart' as http;

class LoyaltyService {
  /// Returns the user's current loyalty tier and points from backend API.
  Future<LoyaltyStatus> getLoyaltyStatus(String userId) async {
    final url = Uri.parse('https://api.oblns.ai/community/loyalty/status');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LoyaltyStatus(
        tier: data['tier'],
        points: data['points'],
      );
    } else {
      throw Exception('Loyalty Status Error: ${response.body}');
    }
  }
}

class LoyaltyStatus {
  final String tier;
  final int points;
  LoyaltyStatus({required this.tier, required this.points});
}
