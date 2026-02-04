import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oblns/core/observability/logging_config.dart';

/// OpenStreetMap Nominatim geocoding service for Libya
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Search for places in Libya by name
  /// Returns list of {name, displayName, lat, lon}
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'countrycodes': 'ly', // Libya only
          'limit': '10',
          'addressdetails': '1',
        },
      );

      final response = await http
          .get(uri, headers: {'User-Agent': 'OBLNSApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        return results
            .map(
              (place) => {
                'name': place['name'] ?? place['display_name'],
                'displayName': place['display_name'],
                'lat': double.parse(place['lat']),
                'lon': double.parse(place['lon']),
                'type': place['type'] ?? 'place',
              },
            )
            .toList();
      } else {
        AppLogger.error('Geocoding failed', 'Status: ${response.statusCode}');
        return [];
      }
    } catch (e, st) {
      AppLogger.error('Geocoding error', e, st);
      return [];
    }
  }

  /// Reverse geocode: get address from coordinates
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
        },
      );

      final response = await http
          .get(uri, headers: {'User-Agent': 'OBLNSApp/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
      return null;
    } catch (e, st) {
      AppLogger.error('Reverse geocoding error', e, st);
      return null;
    }
  }
}
