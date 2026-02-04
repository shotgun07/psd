import 'package:flutter/material.dart';
import 'multi_basket_service.dart';

class MultiBasketScreen extends StatefulWidget {
  const MultiBasketScreen({super.key});

  @override
  State<MultiBasketScreen> createState() => _MultiBasketScreenState();
}

class _MultiBasketScreenState extends State<MultiBasketScreen> {
  final MultiBasketService _service = MultiBasketService();
  final TextEditingController _userIdController = TextEditingController();
  final List<BasketItem> _items = [];
  String? _orderId;
  String? _status;
  String? _error;
  bool _loading = false;

  void _addItem() {
    setState(() {
      _items.add(BasketItem(storeId: '', itemId: '', quantity: 1));
    });
  }

  Future<void> _createOrder() async {
    setState(() {
      _loading = true;
      _error = null;
      _orderId = null;
      _status = null;
    });
    try {
      final order = await _service.createMultiBasketOrder(
        _userIdController.text,
        _items,
      );
      setState(() {
        _orderId = order.orderId;
        _status = order.status;
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
      appBar: AppBar(title: const Text('Multi-Basket Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
            ),
            const SizedBox(height: 16),
            const Text('Basket Items:'),
            ..._items.asMap().entries.map((entry) {
              int idx = entry.key;
              BasketItem item = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Store ID'),
                      onChanged: (v) {
                        // Note: In a real app we'd handle updating items differently
                        // because BasketItem in service is immutable.
                        // For now, replacing the item in the list.
                        _items[idx] = BasketItem(
                          storeId: v,
                          itemId: item.itemId,
                          quantity: item.quantity,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Item ID'),
                      onChanged: (v) {
                        _items[idx] = BasketItem(
                          storeId: item.storeId,
                          itemId: v,
                          quantity: item.quantity,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Qty'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        _items[idx] = BasketItem(
                          storeId: item.storeId,
                          itemId: item.itemId,
                          quantity: int.tryParse(v) ?? 1,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _items.removeAt(idx);
                      });
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addItem, child: const Text('Add Item')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _createOrder,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create Multi-Basket Order'),
            ),
            if (_orderId != null) ...[
              const SizedBox(height: 16),
              Text('Order ID: $_orderId'),
              Text('Status: $_status'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                'Error: \$_error',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
