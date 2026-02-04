import 'package:flutter/material.dart';
import 'commute_service.dart';

class CommuteScreen extends StatefulWidget {
  const CommuteScreen({super.key});

  @override
  State<CommuteScreen> createState() => _CommuteScreenState();
}

class _CommuteScreenState extends State<CommuteScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _planIdController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _subscribe() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = CommuteService();
      await service.subscribeToCommute(
        _userIdController.text,
        _planIdController.text,
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الاشتراك في خطة التنقل بنجاح!')),
      );
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
      appBar: AppBar(title: const Text('اشتراك التنقل المؤسسي')),
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
              controller: _planIdController,
              decoration: const InputDecoration(
                labelText: 'معرف خطة التنقل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _subscribe,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('اشترك'),
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
