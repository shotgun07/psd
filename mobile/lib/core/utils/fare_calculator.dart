import 'package:geolocator/geolocator.dart';

/// Calculate fare based on distance between two coordinates
/// Uses a base rate of 1.5 LYD per kilometer
class FareCalculator {
  static const double _baseRate = 1.5; // LYD per km
  static const double _minimumFare = 5.0; // Minimum fare in LYD

  /// Calculate fare based on distance
  static double calculateFare({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    );

    final distanceInKm = distanceInMeters / 1000;
    final fare = distanceInKm * _baseRate;

    // Ensure minimum fare
    return fare < _minimumFare ? _minimumFare : fare;
  }

  /// Get distance in kilometers
  static double getDistanceInKm({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    );

    return distanceInMeters / 1000;
  }
}
