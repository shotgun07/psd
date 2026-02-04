import 'package:flutter/material.dart';
import 'ledger_service.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController _masterIdController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Map<String, double> _ledger = {};
  bool _loading = false;
  String? _error;

  Future<void> _getLedger() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = LedgerService();
      final ledger = await service.getFamilyLedger(_masterIdController.text);
      setState(() {
        _ledger = ledger;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _setBudget() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = LedgerService();
      await service.setBudget(
        _masterIdController.text,
        _memberIdController.text,
        double.tryParse(_amountController.text) ?? 0,
      );
      await _getLedger();
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
      appBar: AppBar(title: const Text('دفتر العائلة المالي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _masterIdController,
              decoration: const InputDecoration(
                labelText: 'معرف رب الأسرة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memberIdController,
              decoration: const InputDecoration(
                labelText: 'معرف الفرد',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الميزانية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _setBudget,
                    child: const Text('تعيين ميزانية'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _getLedger,
                    child: const Text('عرض دفتر العائلة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_ledger.isNotEmpty)
              ..._ledger.entries.map((e) => ListTile(
                title: Text('الفرد: ${e.key}'),
                subtitle: Text('الميزانية: ${e.value.toStringAsFixed(2)} دينار'),
              )),
          ],
        ),
      ),
    );
  }
}
