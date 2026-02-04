/// SmartBatchingService: Optimizes routes and batches multiple service types for captains.

import 'dart:convert';
import 'package:http/http.dart' as http;

class SmartBatchingService {
  /// Returns an optimized route and service batch for a captain using AI backend.
  Future<SmartBatchingPlan> getOptimizedBatch(String captainId) async {
    final url = Uri.parse('https://api.oblns.ai/smart_batching');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'captainId': captainId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final stops = (data['stops'] as List).map((s) => BatchStop(
        type: s['type'],
        address: s['address'],
      )).toList();
      return SmartBatchingPlan(
        stops: stops,
        estimatedTimeMinutes: data['estimatedTimeMinutes'],
      );
    } else {
      throw Exception('SmartBatching API Error: ${response.body}');
    }
  }
}

class SmartBatchingPlan {
  final List<BatchStop> stops;
  final int estimatedTimeMinutes;
  SmartBatchingPlan({required this.stops, required this.estimatedTimeMinutes});
}

class BatchStop {
  final String type;
  final String address;
  BatchStop({required this.type, required this.address});
}
