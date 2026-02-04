
import 'dart:convert';
import 'package:http/http.dart' as http;

class InventorySyncService {
  /// Syncs inventory for a store using backend API.
  Future<InventorySyncResponse> syncInventory(String storeId, Map<String, int> stock) async {
    final url = Uri.parse('https://api.oblns.ai/b2b/inventory_sync/sync');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'storeId': storeId,
        'stock': stock,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return InventorySyncResponse(
        syncId: data['syncId'],
        status: data['status'],
      );
    } else {
      throw Exception('Inventory Sync Error: ${response.body}');
    }
  }
}

class InventorySyncResponse {
  final String syncId;
  final String status;
  InventorySyncResponse({required this.syncId, required this.status});
}
