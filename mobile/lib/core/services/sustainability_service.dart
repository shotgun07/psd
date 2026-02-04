class SustainabilityService {
  double calculateCarbonFootprint(double distanceKm, String vehicleType) {
    // Emission factors in kg CO2 per km
    final emissionFactors = {
      'car': 0.2,
      'truck': 0.3,
      'motorcycle': 0.1,
      'electric_car': 0.05,
      'bicycle': 0.0,
      'walking': 0.0,
    };

    double emissionFactor = emissionFactors[vehicleType] ?? 0.2;
    return distanceKm * emissionFactor;
  }

  double calculateTripSustainabilityScore(
    double distanceKm,
    String vehicleType,
    double trafficFactor,
    bool isSharedRide,
  ) {
    double baseScore = 100.0;
    double carbonFootprint = calculateCarbonFootprint(distanceKm, vehicleType);

    // Penalize high carbon footprint
    baseScore -= carbonFootprint * 10;

    // Penalize traffic congestion
    baseScore -= trafficFactor * 20;

    // Bonus for shared rides
    if (isSharedRide) {
      baseScore += 15;
    }

    // Bonus for low-emission vehicles
    if (vehicleType == 'electric_car' || vehicleType == 'bicycle') {
      baseScore += 20;
    }

    return baseScore.clamp(0.0, 100.0);
  }

  Map<String, double> getSustainabilityReport(List<Map<String, dynamic>> trips) {
    double totalDistance = 0;
    double totalCarbon = 0;
    int sharedRides = 0;
    Map<String, int> vehicleUsage = {};

    for (final trip in trips) {
      totalDistance += trip['distance'] as double;
      totalCarbon += calculateCarbonFootprint(
        trip['distance'] as double,
        trip['vehicle_type'] as String,
      );

      if (trip['is_shared'] == true) {
        sharedRides++;
      }

      vehicleUsage[trip['vehicle_type'] as String] =
          (vehicleUsage[trip['vehicle_type'] as String] ?? 0) + 1;
    }

    double averageScore = trips.isEmpty
        ? 0
        : trips.map((t) => calculateTripSustainabilityScore(
              t['distance'] as double,
              t['vehicle_type'] as String,
              t['traffic_factor'] as double? ?? 1.0,
              t['is_shared'] as bool? ?? false,
            )).reduce((a, b) => a + b) / trips.length;

    return {
      'total_distance_km': totalDistance,
      'total_carbon_kg': totalCarbon,
      'average_sustainability_score': averageScore,
      'shared_ride_percentage': trips.isEmpty ? 0 : (sharedRides / trips.length) * 100,
      'carbon_per_km': totalDistance == 0 ? 0 : totalCarbon / totalDistance,
    };
  }

  List<String> getSustainabilityTips(double currentScore) {
    List<String> tips = [];

    if (currentScore < 50) {
      tips.add('Consider switching to electric or low-emission vehicles');
      tips.add('Try carpooling to reduce your carbon footprint');
      tips.add('Avoid peak traffic hours to minimize emissions');
    } else if (currentScore < 75) {
      tips.add('Great job! Try using public transport for some trips');
      tips.add('Consider biking for short distances');
    } else {
      tips.add('Excellent sustainability score! Keep up the good work');
      tips.add('Share your sustainable practices with other drivers');
    }

    return tips;
  }
}