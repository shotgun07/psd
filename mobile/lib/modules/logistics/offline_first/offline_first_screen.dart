import 'package:flutter/material.dart';
import 'offline_first_service.dart';

class OfflineFirstScreen extends StatefulWidget {
  @override
  _OfflineFirstScreenState createState() => _OfflineFirstScreenState();
}

class _OfflineFirstScreenState extends State<OfflineFirstScreen> {
  final OfflineFirstService _service = OfflineFirstService();
  final TextEditingController _userIdController = TextEditingController();
  final List<BasketItem> _items = [];
  String? _orderId;
  String? _status;
  String? _fallbackMethod;
  String? _error;
  bool _loading = false;

  void _addItem() {
    setState(() {
      _items.add(BasketItem(storeId: '', itemId: '', quantity: 1));
    });
  }

  Future<void> _placeOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _orderId = null;
      _status = null;
      _fallbackMethod = null;
    });
    try {
      final resp = await _service.placeOrderOffline(
        _userIdController.text,
        _items,
      );
      setState(() {
        _orderId = resp.orderId;
        _status = resp.status;
        _fallbackMethod = resp.fallbackMethod;
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
      appBar: AppBar(title: Text('Offline-First Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            SizedBox(height: 16),
            Text('Basket Items:'),
            ..._items.asMap().entries.map((entry) {
              int idx = entry.key;
              BasketItem item = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Store ID'),
                      onChanged: (v) => item.storeId = v,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Item ID'),
                      onChanged: (v) => item.itemId = v,
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Qty'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => item.quantity = int.tryParse(v) ?? 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _items.removeAt(idx);
                      });
                    },
                  ),
                ],
              );
            }).toList(),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add Item'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _placeOrder,
              child: _loading ? CircularProgressIndicator() : Text('Place Offline Order'),
            ),
            if (_orderId != null) ...[
              SizedBox(height: 16),
              Text('Order ID: $_orderId'),
              Text('Status: $_status'),
              Text('Fallback Method: $_fallbackMethod'),
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
