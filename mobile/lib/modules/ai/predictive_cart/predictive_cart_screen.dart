import 'package:flutter/material.dart';
import 'predictive_cart_service.dart';

class PredictiveCartScreen extends StatefulWidget {
  const PredictiveCartScreen({super.key});

  @override
  State<PredictiveCartScreen> createState() => _PredictiveCartScreenState();
}

class _PredictiveCartScreenState extends State<PredictiveCartScreen> {
  final TextEditingController _userIdController = TextEditingController();
  List<CartItem> _items = [];
  bool _loading = false;
  String? _error;

  Future<void> _fetchCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = PredictiveCartService();
      final items = await service.getPredictedCart(_userIdController.text);
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العربة التنبؤية الذكية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _fetchCart,
              child: _loading ? const CircularProgressIndicator() : const Text('توقع العربة'),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final scheduledTimeText = item.scheduledTime != null ? " - الوقت: ${item.scheduledTime}" : "";
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('الكمية: ${item.quantity}$scheduledTimeText'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
