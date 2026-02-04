/// DesignatedDriverService: Premium option to hire a vetted driver for user's own vehicle.

import 'dart:convert';
import 'package:http/http.dart' as http;

class DesignatedDriverService {
  /// Books a designated driver for a user using backend API.
  Future<void> bookDesignatedDriver(String userId, String vehicleId, DateTime dateTime) async {
    final url = Uri.parse('https://api.oblns.ai/designated_driver/book');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'vehicleId': vehicleId,
        'dateTime': dateTime.toIso8601String(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('DesignatedDriver Book Error: ${response.body}');
    }
  }
}
