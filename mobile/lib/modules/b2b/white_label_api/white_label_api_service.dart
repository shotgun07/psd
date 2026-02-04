

import 'dart:convert';
import 'package:http/http.dart' as http;

class WhiteLabelApiService {
  /// Books a delivery for a business using backend API.
  Future<WhiteLabelBookingResponse> bookDelivery(String businessId, String from, String to, List<String> items) async {
    final url = Uri.parse('https://api.oblns.ai/b2b/white_label_api/book');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'businessId': businessId,
        'from': from,
        'to': to,
        'items': items,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WhiteLabelBookingResponse(
        bookingId: data['bookingId'],
        status: data['status'],
      );
    } else {
      throw Exception('White Label Booking Error: ${response.body}');
    }
  }
}

class WhiteLabelBookingResponse {
  final String bookingId;
  final String status;
  WhiteLabelBookingResponse({required this.bookingId, required this.status});
}
