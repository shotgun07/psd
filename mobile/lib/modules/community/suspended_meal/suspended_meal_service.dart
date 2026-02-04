/// SuspendedMealService: CSR tool for donating meals.

import 'dart:convert';
import 'package:http/http.dart' as http;

class SuspendedMealService {
  /// Donates a meal to someone in need using backend API.
  Future<SuspendedMealDonationResponse> donateMeal(String userId, String restaurantId) async {
    final url = Uri.parse('https://api.oblns.ai/community/suspended_meal/donate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'restaurantId': restaurantId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SuspendedMealDonationResponse(
        donationId: data['donationId'],
        status: data['status'],
      );
    } else {
      throw Exception('Suspended Meal Donation Error: ${response.body}');
    }
  }
}

class SuspendedMealDonationResponse {
  final String donationId;
  final String status;
  SuspendedMealDonationResponse({required this.donationId, required this.status});
}
