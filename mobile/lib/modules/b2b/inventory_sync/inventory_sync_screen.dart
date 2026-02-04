import 'package:flutter/material.dart';
import 'dart:convert';
import 'inventory_sync_service.dart';

class InventorySyncScreen extends StatefulWidget {
  @override
  _InventorySyncScreenState createState() => _InventorySyncScreenState();
}

class _InventorySyncScreenState extends State<InventorySyncScreen> {
  final InventorySyncService _service = InventorySyncService();
  final TextEditingController _storeIdController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _syncId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _syncInventory() async {
    setState(() {
      _loading = true;
      _error = null;
      _syncId = null;
      _status = null;
    });
    try {
      final stock = Map<String, int>.from(jsonDecode(_stockController.text));
      final resp = await _service.syncInventory(
        _storeIdController.text,
        stock,
      );
      setState(() {
        _syncId = resp.syncId;
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
      appBar: AppBar(title: Text('Inventory Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _storeIdController,
              decoration: InputDecoration(labelText: 'Store ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock (JSON: {"item1": 10, ...})'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _syncInventory,
              child: _loading ? CircularProgressIndicator() : Text('Sync Inventory'),
            ),
            if (_syncId != null) ...[
              SizedBox(height: 16),
              Text('Sync ID: $_syncId'),
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
