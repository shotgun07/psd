/// ArNavigationService: AR overlay for last-mile navigation.


import 'dart:convert';
import 'package:http/http.dart' as http;

class ArNavigationService {
  /// Provides AR navigation instructions to the exact delivery point using backend API.
  Future<List<ArInstruction>> getArRoute(String orderId) async {
    final url = Uri.parse('https://api.oblns.ai/ar_navigation/route');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['instructions'] as List)
          .map((i) => ArInstruction(
                step: i['step'] as String? ?? '',
                imageOverlay: i['imageOverlay'] as String? ?? '',
              ))
          .toList();
    } else {
      throw Exception('AR Navigation Error: ${response.body}');
    }
  }
}

class ArInstruction {
  final String step;
  final String imageOverlay;
  ArInstruction({required this.step, required this.imageOverlay});
}
