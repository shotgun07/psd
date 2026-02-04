/// LiveKitchenService: Streams live kitchen feeds for premium restaurants.

import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveKitchenService {
  /// Starts a live stream for a restaurant using backend API.
  Future<LiveFeedResponse> startLiveFeed(String restaurantId) async {
    final url = Uri.parse('https://api.oblns.ai/community/live_kitchen/start');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'restaurantId': restaurantId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LiveFeedResponse(
        streamUrl: data['streamUrl'],
        status: data['status'],
      );
    } else {
      throw Exception('Live Kitchen Feed Error: ${response.body}');
    }
  }
}

class LiveFeedResponse {
  final String streamUrl;
  final String status;
  LiveFeedResponse({required this.streamUrl, required this.status});
}
