import 'package:flutter/material.dart';
import 'utility_bills_service.dart';

class UtilityBillsScreen extends StatefulWidget {
  const UtilityBillsScreen({super.key});

  @override
  State<UtilityBillsScreen> createState() => _UtilityBillsScreenState();
}

class _UtilityBillsScreenState extends State<UtilityBillsScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _billTypeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _payBill() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = UtilityBillsService();
      await service.payBill(
        _userIdController.text,
        _billTypeController.text,
        double.tryParse(_amountController.text) ?? 0,
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم دفع الفاتورة بنجاح!')));
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
      appBar: AppBar(title: const Text('دفع الفواتير')),
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
            const SizedBox(height: 12),
            TextField(
              controller: _billTypeController,
              decoration: const InputDecoration(
                labelText: 'نوع الفاتورة (كهرباء، ماء، ...)',
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
              onPressed: _loading ? null : _payBill,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('دفع'),
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
