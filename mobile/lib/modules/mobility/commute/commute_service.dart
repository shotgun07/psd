/// CommuteService: Corporate commute subscriptions and carpooling.

import 'dart:convert';
import 'package:http/http.dart' as http;

class CommuteService {
  /// Subscribes a user to a corporate commute plan using backend API.
  Future<void> subscribeToCommute(String userId, String planId) async {
    final url = Uri.parse('https://api.oblns.ai/commute/subscribe');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'planId': planId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Commute Subscribe Error: ${response.body}');
    }
  }
}
