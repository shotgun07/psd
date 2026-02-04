/// GeoFencingService: Real-time adjustment of delivery zones.

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoFencingService {
  /// Adjusts delivery zone based on traffic, weather, and fleet using backend API.
  Future<GeoFencingResponse> adjustZone(String zoneId, Map<String, dynamic> context) async {
    final url = Uri.parse('https://api.oblns.ai/b2b/geo_fencing/adjust');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'zoneId': zoneId,
        'context': context,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GeoFencingResponse(
        adjustmentId: data['adjustmentId'],
        status: data['status'],
      );
    } else {
      throw Exception('GeoFencing Adjustment Error: ${response.body}');
    }
  }
}

class GeoFencingResponse {
  final String adjustmentId;
  final String status;
  GeoFencingResponse({required this.adjustmentId, required this.status});
}
