import 'package:flutter/material.dart';
import 'smart_batching_service.dart';

class SmartBatchingScreen extends StatefulWidget {
  const SmartBatchingScreen({Key? key}) : super(key: key);

  @override
  State<SmartBatchingScreen> createState() => _SmartBatchingScreenState();
}

class _SmartBatchingScreenState extends State<SmartBatchingScreen> {
  final TextEditingController _captainIdController = TextEditingController();
  SmartBatchingPlan? _plan;
  bool _loading = false;
  String? _error;

  Future<void> _fetchPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = SmartBatchingService();
      final plan = await service.getOptimizedBatch(_captainIdController.text);
      setState(() {
        _plan = plan;
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
      appBar: AppBar(title: const Text('التجميع الذكي للمسارات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _captainIdController,
              decoration: const InputDecoration(
                labelText: 'Captain ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _fetchPlan,
              child: _loading ? const CircularProgressIndicator() : const Text('احصل على خطة التجميع'),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_plan != null) ...[
              Text('الوقت المقدر: ${_plan!.estimatedTimeMinutes} دقيقة'),
              ..._plan!.stops.map((s) => ListTile(
                title: Text(s.type),
                subtitle: Text(s.address),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
