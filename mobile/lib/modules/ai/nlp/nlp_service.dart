import 'dart:convert';
import 'package:http/http.dart' as http;

/// NLP Service: Handles natural language processing for local dialects and complex commands.
/// This is a stub for the proprietary NLP engine.
class NlpService {
  /// Parses a user command (text or voice) and returns a structured intent using OpenAI API.
  Future<NlpIntent> parseCommand(String input) async {
    final apiKey = const String.fromEnvironment('OPENAI_API_KEY');
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'أنت مساعد ذكي يفهم أوامر المستخدم باللهجة المحلية ويستخرج النية (action) والكائنات (entities) بشكل JSON.'},
          {'role': 'user', 'content': input},
        ],
        'max_tokens': 100,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final json = jsonDecode(content);
      return NlpIntent(
        action: json['action'] ?? '',
        entities: Map<String, String>.from(json['entities'] ?? {}),
      );
    } else {
      throw Exception('NLP API Error: \${response.body}');
    }
  }
}

class NlpIntent {
  final String action;
  final Map<String, String> entities;
  NlpIntent({required this.action, required this.entities});
}
