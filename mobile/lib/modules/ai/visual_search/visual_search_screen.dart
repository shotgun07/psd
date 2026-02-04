import 'dart:io';
import 'package:flutter/material.dart';
import 'visual_search_service.dart';
import 'package:image_picker/image_picker.dart';

class VisualSearchScreen extends StatefulWidget {
  const VisualSearchScreen({super.key});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  XFile? _image;
  List<VisualSearchResult> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = picked);
      await _analyzeImage(picked.path);
    }
  }

  Future<void> _analyzeImage(String path) async {
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final service = VisualSearchService();
      final results = await service.searchFromImage(path);
      setState(() {
        _results = results;
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
      appBar: AppBar(title: const Text('البحث البصري الذكي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _pickImage,
              child: const Text('اختر صورة'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              Image.file(
                File(_image!.path),
                height: 150,
              ),
            ],
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final r = _results[index];
                  return ListTile(
                    title: Text(r.item),
                    subtitle: Text('الأقرب: \${r.merchant} (\${r.distanceMeters} متر)'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
