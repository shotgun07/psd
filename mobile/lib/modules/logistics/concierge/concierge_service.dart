/// ConciergeService: Hyper-local concierge for custom pickup/delivery tasks.

import 'dart:convert';
import 'package:http/http.dart' as http;

class ConciergeService {
  /// Requests a custom pickup or delivery task using backend API.
  Future<ConciergeTaskResponse> requestConciergeTask(String userId, String description, String location) async {
    final url = Uri.parse('https://api.oblns.ai/concierge/request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'description': description,
        'location': location,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConciergeTaskResponse(
        taskId: data['taskId'],
        status: data['status'],
      );
    } else {
      throw Exception('Concierge Task Error: ${response.body}');
    }
  }
}

class ConciergeTaskResponse {
  final String taskId;
  final String status;
  ConciergeTaskResponse({required this.taskId, required this.status});
}
