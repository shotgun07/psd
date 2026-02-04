import 'package:flutter/material.dart';
import 'payouts_service.dart';

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  final TextEditingController _captainIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _withdraw() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = PayoutsService();
      await service.withdrawEarnings(
        _captainIdController.text,
        double.tryParse(_amountController.text) ?? 0,
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم سحب الأرباح بنجاح!')));
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
      appBar: AppBar(title: const Text('سحب أرباح الكباتن')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captainIdController,
              decoration: const InputDecoration(
                labelText: 'معرف الكابتن',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _withdraw,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('سحب'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
