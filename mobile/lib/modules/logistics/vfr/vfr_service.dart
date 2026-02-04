/// VfrService: Virtual Fitting Room for fashion retailers.

import 'dart:convert';
import 'package:http/http.dart' as http;

class VfrService {
  /// Simulates trying on an item using AR via backend API.
  Future<VfrResult> tryOnItem(String userId, String itemId, String imagePath) async {
    final url = Uri.parse('https://api.oblns.ai/vfr/tryon');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'itemId': itemId,
        'imagePath': imagePath,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VfrResult(
        success: data['success'],
        previewImage: data['previewImage'],
      );
    } else {
      throw Exception('VFR TryOn Error: ${response.body}');
    }
  }
}

class VfrResult {
  final bool success;
  final String previewImage;
  VfrResult({required this.success, required this.previewImage});
}
