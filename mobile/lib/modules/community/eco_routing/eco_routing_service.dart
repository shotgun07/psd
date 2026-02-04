/// EcoRoutingService: Eco-friendly routing and carbon tracking.

import 'dart:convert';
import 'package:http/http.dart' as http;

class EcoRoutingService {
  /// Calculates eco-friendly route and rewards using backend API.
  Future<EcoRouteResult> getEcoRoute(String from, String to) async {
    final url = Uri.parse('https://api.oblns.ai/community/eco_routing/route');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'from': from, 'to': to}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return EcoRouteResult(
        distance: data['distance'],
        carbonSaved: data['carbonSaved'],
        rewardPoints: data['rewardPoints'],
      );
    } else {
      throw Exception('Eco Routing Error: ${response.body}');
    }
  }
}

class EcoRouteResult {
  final double distance;
  final double carbonSaved;
  final int rewardPoints;
  EcoRouteResult({required this.distance, required this.carbonSaved, required this.rewardPoints});
}
