import 'package:flutter/material.dart';
import 'safety_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({Key? key}) : super(key: key);

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final TextEditingController _rideIdController = TextEditingController();
  bool? _safe;
  bool _loading = false;
  String? _error;

  Future<void> _monitorRide() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = SafetyService();
      final safe = await service.monitorRide(_rideIdController.text);
      setState(() {
        _safe = safe;
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
      appBar: AppBar(title: const Text('مراقبة أمان الرحلة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rideIdController,
              decoration: const InputDecoration(
                labelText: 'معرف الرحلة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _monitorRide,
              child: _loading ? const CircularProgressIndicator() : const Text('مراقبة الرحلة'),
            ),
            const SizedBox(height: 24),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_safe != null)
              Text(_safe! ? 'الرحلة آمنة' : 'تنبيه: هناك خطر أو انحراف!', style: TextStyle(color: _safe! ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}
