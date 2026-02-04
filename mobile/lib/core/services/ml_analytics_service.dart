import 'package:ml_linalg/ml_linalg.dart';

class MLAnalyticsService {
  Future<double> predictDemand(List<double> historicalData) async {
    // Simple moving average prediction
    if (historicalData.isEmpty) return 0.0;
    final sum = historicalData.reduce((a, b) => a + b);
    return sum / historicalData.length;
  }

  Future<List<double>> predictRouteOptimization(
    List<List<double>> routeData,
    List<double> targets,
  ) async {
    // Simple average calculation
    if (routeData.isEmpty) return [0.0];
    final averages = <double>[];
    for (int i = 0; i < routeData[0].length; i++) {
      double sum = 0;
      for (final row in routeData) {
        sum += row[i];
      }
      averages.add(sum / routeData.length);
    }
    return averages;
  }

  Future<String> classifyDriverBehavior(List<double> features) async {
    // Simple rule-based classification
    final speed = features[0];
    final braking = features[1];
    final attention = features[2];

    if (speed > 100 || braking > 10 || attention < 3) {
      return 'aggressive';
    } else if (speed > 80 || braking > 5) {
      return 'normal';
    } else {
      return 'safe';
    }
  }

  Future<double> predictETA(
    double distance,
    double trafficFactor,
    List<double> historicalETAs,
  ) async {
    // Simple average ETA prediction
    if (historicalETAs.isEmpty) return distance * 0.1; // 10 min per 100km
    final avgETA = historicalETAs.reduce((a, b) => a + b) / historicalETAs.length;
    return avgETA * (1 + trafficFactor * 0.5); // Adjust for traffic
  }

  Future<Map<String, double>> analyzeTripPatterns(List<Map<String, dynamic>> trips) async {
    // Analyze trip data for patterns
    final distances = trips.map((t) => t['distance'] as double).toList();
    final fares = trips.map((t) => t['fare'] as double).toList();

    final avgDistance = distances.reduce((a, b) => a + b) / distances.length;
    final avgFare = fares.reduce((a, b) => a + b) / fares.length;

    // Simple correlation
    final correlation = _calculateCorrelation(distances, fares);

    return {
      'average_distance': avgDistance,
      'average_fare': avgFare,
      'distance_fare_correlation': correlation,
    };
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((e) => e * e).reduce((a, b) => a + b);
    final sumY2 = y.map((e) => e * e).reduce((a, b) => a + b);

    final numerator = n * sumXY - sumX * sumY;
    final denominator = (n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY);

    return denominator == 0 ? 0 : numerator / denominator;
  }
}
