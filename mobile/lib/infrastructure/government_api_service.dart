import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GovernmentAPIService {
  final String _baseUrl = 'https://api.libya.gov';
  final String _apiKey = dotenv.env['GOV_API_KEY'] ?? '';

  Future<Map<String, dynamic>> verifyDriverLicense(String licenseNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/driver-license/$licenseNumber'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify license: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': e.toString(), 'verified': false};
    }
  }

  Future<Map<String, dynamic>> verifyVehicleRegistration(String plateNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vehicle-registration/$plateNumber'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify vehicle: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': e.toString(), 'verified': false};
    }
  }

  Future<Map<String, dynamic>> checkCriminalRecord(String nationalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/criminal-record/$nationalId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check record: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': e.toString(), 'hasRecord': false};
    }
  }

  Future<Map<String, dynamic>> getTrafficViolations(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/traffic-violations/$driverId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get violations: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': e.toString(), 'violations': []};
    }
  }

  Future<bool> submitTripReport(Map<String, dynamic> tripData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/trip-reports'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tripData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getWeatherData(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/$location'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get weather: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': e.toString(), 'weather': 'unknown'};
    }
  }
}