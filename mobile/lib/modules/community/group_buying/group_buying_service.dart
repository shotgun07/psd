/// GroupBuyingService: Handles group-buying discounts and social commerce.

import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupBuyingService {
  /// Creates a group-buying order for a set of users using backend API.
  Future<GroupOrderResponse> createGroupOrder(List<String> userIds, String merchantId, List<String> itemIds) async {
    final url = Uri.parse('https://api.oblns.ai/community/group_buying/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userIds': userIds,
        'merchantId': merchantId,
        'itemIds': itemIds,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GroupOrderResponse(
        orderId: data['orderId'],
        status: data['status'],
      );
    } else {
      throw Exception('Group Buying Order Error: ${response.body}');
    }
  }
}

class GroupOrderResponse {
  final String orderId;
  final String status;
  GroupOrderResponse({required this.orderId, required this.status});
}
