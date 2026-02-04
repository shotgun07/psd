import 'package:flutter/material.dart';
import 'emotion_ux_service.dart';

class EmotionUxScreen extends StatefulWidget {
  const EmotionUxScreen({super.key});

  @override
  State<EmotionUxScreen> createState() => _EmotionUxScreenState();
}

class _EmotionUxScreenState extends State<EmotionUxScreen> {
  final TextEditingController _userIdController = TextEditingController();
  EmotionUxRecommendation? _recommendation;
  bool _loading = false;
  String? _error;

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = EmotionUxService();
      final rec = await service.analyzeUserSentiment(_userIdController.text);
      setState(() {
        _recommendation = rec;
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
      appBar: AppBar(title: const Text('تخصيص تجربة المستخدم الذكي')),
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
              onPressed: _loading ? null : _analyze,
              child: _loading ? const CircularProgressIndicator() : const Text('تحليل المشاعر'),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_recommendation != null) ...[
              Text('لوحة الألوان: ${_recommendation!.colorPalette}'),
              Text('النبرة: ${_recommendation!.tone}'),
              Text('سرعة التوصيل: ${_recommendation!.deliverySpeed}'),
            ],
          ],
        ),
      ),
    );
  }
}
