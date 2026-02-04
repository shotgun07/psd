import 'package:flutter/material.dart';
import 'vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  double? _balance;
  bool _loading = false;
  String? _error;

  Future<void> _getBalance() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = VaultService();
      final balance = await service.getVaultBalance(_userIdController.text);
      setState(() {
        _balance = balance;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deposit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = VaultService();
      await service.depositChange(_userIdController.text, double.tryParse(_amountController.text) ?? 0);
      await _getBalance();
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
      appBar: AppBar(title: const Text('المحفظة الرقمية (Vault)')),
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
                labelText: 'المبلغ للإيداع',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _deposit,
                    child: const Text('إيداع فكة'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _getBalance,
                    child: const Text('عرض الرصيد'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_balance != null) Text('الرصيد الحالي: ${_balance!.toStringAsFixed(2)} دينار'),
          ],
        ),
      ),
    );
  }
}
