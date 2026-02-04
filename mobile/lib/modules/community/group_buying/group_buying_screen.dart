import 'package:flutter/material.dart';
import 'group_buying_service.dart';

class GroupBuyingScreen extends StatefulWidget {
  @override
  _GroupBuyingScreenState createState() => _GroupBuyingScreenState();
}

class _GroupBuyingScreenState extends State<GroupBuyingScreen> {
  final GroupBuyingService _service = GroupBuyingService();
  final TextEditingController _userIdsController = TextEditingController();
  final TextEditingController _merchantIdController = TextEditingController();
  final TextEditingController _itemIdsController = TextEditingController();
  String? _orderId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _createGroupOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _orderId = null;
      _status = null;
    });
    try {
      final userIds = _userIdsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final itemIds = _itemIdsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final resp = await _service.createGroupOrder(
        userIds,
        _merchantIdController.text,
        itemIds,
      );
      setState(() {
        _orderId = resp.orderId;
        _status = resp.status;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Buying')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdsController,
              decoration: InputDecoration(labelText: 'User IDs (comma separated)'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _merchantIdController,
              decoration: InputDecoration(labelText: 'Merchant ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemIdsController,
              decoration: InputDecoration(labelText: 'Item IDs (comma separated)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _createGroupOrder,
              child: _loading ? CircularProgressIndicator() : Text('Create Group Order'),
            ),
            if (_orderId != null) ...[
              SizedBox(height: 16),
              Text('Order ID: $_orderId'),
              Text('Status: $_status'),
            ],
            if (_error != null) ...[
              SizedBox(height: 16),
              Text('Error: $_error', style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
