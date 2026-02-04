/// AuctionService: Reverse auction bidding for long-distance trips.

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuctionService {
  /// Posts a route and collects driver bids in real-time from backend.
  Future<List<DriverBid>> postRouteAndCollectBids(String userId, String from, String to) async {
    final url = Uri.parse('https://api.oblns.ai/auction/bids');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'from': from, 'to': to}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => DriverBid(
        driverId: item['driverId'],
        price: (item['price'] as num).toDouble(),
      )).toList();
    } else {
      throw Exception('Auction Bids Error: ${response.body}');
    }
  }
}

class DriverBid {
  final String driverId;
  final double price;
  DriverBid({required this.driverId, required this.price});
}
