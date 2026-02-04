/// DemandForecastingService: Predicts demand for merchants based on events/trends.

import 'dart:convert';
import 'package:http/http.dart' as http;

class DemandForecastingService {
  /// Returns demand forecast for a merchant using backend API.
  Future<DemandForecast> getForecast(String merchantId) async {
    final url = Uri.parse('https://api.oblns.ai/b2b/demand_forecasting/forecast');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'merchantId': merchantId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DemandForecast(
        predictedOrders: data['predictedOrders'],
        trend: data['trend'],
      );
    } else {
      throw Exception('Demand Forecast Error: ${response.body}');
    }
  }
}

class DemandForecast {
  final int predictedOrders;
  final String trend;
  DemandForecast({required this.predictedOrders, required this.trend});
}
