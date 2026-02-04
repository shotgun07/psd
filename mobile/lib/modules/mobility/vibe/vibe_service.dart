/// VibeService: Manages ride presets (music, temperature, quiet mode).

import 'dart:convert';
import 'package:http/http.dart' as http;

class VibeService {
  /// Sets ride preferences for the user using backend API.
  Future<void> setVibePreferences(String userId, VibePreferences prefs) async {
    final url = Uri.parse('https://api.oblns.ai/vibe/set');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'musicGenre': prefs.musicGenre,
        'temperature': prefs.temperature,
        'quietMode': prefs.quietMode,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Vibe Set Error: ${response.body}');
    }
  }
}

class VibePreferences {
  final String musicGenre;
  final double temperature;
  final bool quietMode;
  VibePreferences({required this.musicGenre, required this.temperature, required this.quietMode});
}
