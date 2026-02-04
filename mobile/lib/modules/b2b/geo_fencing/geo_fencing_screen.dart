import 'package:flutter/material.dart';
import 'dart:convert';
import 'geo_fencing_service.dart';

class GeoFencingScreen extends StatefulWidget {
  @override
  _GeoFencingScreenState createState() => _GeoFencingScreenState();
}

class _GeoFencingScreenState extends State<GeoFencingScreen> {
  final GeoFencingService _service = GeoFencingService();
  final TextEditingController _zoneIdController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  String? _adjustmentId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _adjustZone() async {
    setState(() {
      _loading = true;
      _error = null;
      _adjustmentId = null;
      _status = null;
    });
    try {
      final contextMap = Map<String, dynamic>.from(jsonDecode(_contextController.text));
      final resp = await _service.adjustZone(
        _zoneIdController.text,
        contextMap,
      );
      setState(() {
        _adjustmentId = resp.adjustmentId;
        _status = resp.status;
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
      appBar: AppBar(title: Text('GeoFencing Adjustment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _zoneIdController,
              decoration: InputDecoration(labelText: 'Zone ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _contextController,
              decoration: InputDecoration(labelText: 'Context (JSON)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _adjustZone,
              child: _loading ? CircularProgressIndicator() : Text('Adjust Zone'),
            ),
            if (_adjustmentId != null) ...[
              SizedBox(height: 16),
              Text('Adjustment ID: $_adjustmentId'),
              Text('Status: $_status'),
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
