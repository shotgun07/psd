import 'package:flutter/material.dart';
import 'bnpl_service.dart';

class BnplScreen extends StatefulWidget {
  const BnplScreen({super.key});

  @override
  State<BnplScreen> createState() => _BnplScreenState();
}

class _BnplScreenState extends State<BnplScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool? _eligible;
  bool _loading = false;
  String? _error;

  Future<void> _checkEligibility() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = BNPLService();
      final eligible = await service.isEligible(_userIdController.text);
      setState(() {
        _eligible = eligible;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = BNPLService();
      await service.createBnplOrder(
        _userIdController.text,
        double.tryParse(_amountController.text) ?? 0,
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء طلب BNPL بنجاح!')));
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
      appBar: AppBar(title: const Text('اشترِ الآن وادفع لاحقًا (BNPL)')),
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
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _checkEligibility,
                    child: const Text('تحقق من الأهلية'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_loading || _eligible != true)
                        ? null
                        : _createOrder,
                    child: const Text('إنشاء طلب BNPL'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_eligible != null)
              Text(
                _eligible! ? 'مؤهل لـ BNPL' : 'غير مؤهل لـ BNPL',
                style: TextStyle(color: _eligible! ? Colors.green : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
