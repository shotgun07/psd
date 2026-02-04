import 'dart:convert';
import 'package:http/http.dart' as http;

/// EmotionUxService: Adapts UI/UX based on user sentiment and interaction patterns.
class EmotionUxService {
  /// Analyzes user interaction and returns a recommended UI theme and tone using AI API.
  Future<EmotionUxRecommendation> analyzeUserSentiment(String userId) async {
    final url = Uri.parse('https://api.oblns.ai/emotion_ux');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return EmotionUxRecommendation(
        colorPalette: data['colorPalette'],
        tone: data['tone'],
        deliverySpeed: data['deliverySpeed'],
      );
    } else {
      throw Exception('EmotionUx API Error: ${response.body}');
    }
  }
}

class EmotionUxRecommendation {
  final String colorPalette;
  final String tone;
  final String deliverySpeed;
  EmotionUxRecommendation({required this.colorPalette, required this.tone, required this.deliverySpeed});
}
