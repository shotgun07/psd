import 'package:flutter/material.dart';
import 'nlp_service.dart';

class NlpScreen extends StatefulWidget {
  const NlpScreen({super.key});

  @override
  State<NlpScreen> createState() => _NlpScreenState();
}

class _NlpScreenState extends State<NlpScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _loading = false;

  Future<void> _analyze() async {
    setState(() => _loading = true);
    final service = NlpService();
    final intent = await service.parseCommand(_controller.text);
    setState(() {
      _result = 'Action: ${intent.action}\nEntities: ${intent.entities}';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NLP الذكاء الاصطناعي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'اكتب أمرك أو صوتك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _analyze,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('تحليل'),
            ),
            const SizedBox(height: 24),
            Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
