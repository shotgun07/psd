import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'vfr_service.dart';

class VfrScreen extends StatefulWidget {
  @override
  _VfrScreenState createState() => _VfrScreenState();
}

class _VfrScreenState extends State<VfrScreen> {
  final VfrService _service = VfrService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _itemIdController = TextEditingController();
  File? _selectedImage;
  String? _previewImage;
  String? _error;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _tryOn() async {
    if (_selectedImage == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _previewImage = null;
    });
    try {
      final result = await _service.tryOnItem(
        _userIdController.text,
        _itemIdController.text,
        _selectedImage!.path,
      );
      setState(() {
        _previewImage = result.previewImage;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Fitting Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemIdController,
              decoration: InputDecoration(labelText: 'Item ID'),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Image'),
                ),
                if (_selectedImage != null) ...[
                  SizedBox(width: 8),
                  Text('Image selected'),
                ],
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading || _selectedImage == null ? null : _tryOn,
              child: _loading ? CircularProgressIndicator() : Text('Try On'),
            ),
            if (_previewImage != null) ...[
              SizedBox(height: 16),
              Text('Preview:'),
              Image.network(_previewImage!),
            ],
            if (_error != null) ...[
              SizedBox(height: 16),
              Text('Error: $_error', style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
