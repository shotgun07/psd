import 'package:flutter/material.dart';
import 'vibe_service.dart';

class VibeScreen extends StatefulWidget {
  const VibeScreen({super.key});

  @override
  State<VibeScreen> createState() => _VibeScreenState();
}

class _VibeScreenState extends State<VibeScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _musicController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  bool _quietMode = false;
  bool _loading = false;
  String? _error;

  Future<void> _setVibe() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = VibeService();
      await service.setVibePreferences(
        _userIdController.text,
        VibePreferences(
          musicGenre: _musicController.text,
          temperature: double.tryParse(_tempController.text) ?? 22.0,
          quietMode: _quietMode,
        ),
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ التفضيلات بنجاح!')));
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
      appBar: AppBar(title: const Text('تفضيلات الرحلة (Vibe)')),
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
              controller: _musicController,
              decoration: const InputDecoration(
                labelText: 'نوع الموسيقى',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tempController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'درجة الحرارة (°C)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _quietMode,
                  onChanged: (v) => setState(() => _quietMode = v ?? false),
                ),
                const Text('وضع الصمت (بدون حديث)'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _setVibe,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ التفضيلات'),
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
