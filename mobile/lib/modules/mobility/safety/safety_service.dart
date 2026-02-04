/// SafetyService: Guardian Angel AI safety mode for rides.

import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyService {
  /// Monitors ride for distress or route deviation using AI backend.
  Future<bool> monitorRide(String rideId) async {
    final url = Uri.parse('https://api.oblns.ai/safety/monitor');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rideId': rideId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['safe'] == true;
    } else {
      throw Exception('Safety Monitor Error: ${response.body}');
    }
  }
}
