import 'package:flutter/material.dart';
import 'live_kitchen_service.dart';

class LiveKitchenScreen extends StatefulWidget {
  @override
  _LiveKitchenScreenState createState() => _LiveKitchenScreenState();
}

class _LiveKitchenScreenState extends State<LiveKitchenScreen> {
  final LiveKitchenService _service = LiveKitchenService();
  final TextEditingController _restaurantIdController = TextEditingController();
  String? _streamUrl;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _startFeed() async {
    setState(() {
      _loading = true;
      _error = null;
      _streamUrl = null;
      _status = null;
    });
    try {
      final resp = await _service.startLiveFeed(_restaurantIdController.text);
      setState(() {
        _streamUrl = resp.streamUrl;
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
      appBar: AppBar(title: Text('Live Kitchen Feed')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _restaurantIdController,
              decoration: InputDecoration(labelText: 'Restaurant ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _startFeed,
              child: _loading ? CircularProgressIndicator() : Text('Start Live Feed'),
            ),
            if (_streamUrl != null) ...[
              SizedBox(height: 16),
              Text('Status: $_status'),
              Text('Stream URL: $_streamUrl'),
              // In production, use a video player widget for the stream
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
