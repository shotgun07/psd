import 'dart:convert';
import 'package:http/http.dart' as http;

/// VisualSearchService: Identifies items from photos and finds the closest merchant.
class VisualSearchService {
  /// Takes an image and returns a list of identified items and suggested merchants using AI API.
  Future<List<VisualSearchResult>> searchFromImage(String imagePath) async {
    final url = Uri.parse('https://api.oblns.ai/visual_search');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => VisualSearchResult(
        item: item['item'],
        merchant: item['merchant'],
        distanceMeters: item['distanceMeters'],
      )).toList();
    } else {
      throw Exception('VisualSearch API Error: \${response.body}');
    }
  }
}

class VisualSearchResult {
  final String item;
  final String merchant;
  final int distanceMeters;
  VisualSearchResult({required this.item, required this.merchant, required this.distanceMeters});
}
