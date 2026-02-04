import 'package:flutter/material.dart';
import 'concierge_service.dart';

class ConciergeScreen extends StatefulWidget {
  @override
  _ConciergeScreenState createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  final ConciergeService _service = ConciergeService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _taskId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _requestTask() async {
    setState(() {
      _loading = true;
      _error = null;
      _taskId = null;
      _status = null;
    });
    try {
      final resp = await _service.requestConciergeTask(
        _userIdController.text,
        _descController.text,
        _locationController.text,
      );
      setState(() {
        _taskId = resp.taskId;
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
      appBar: AppBar(title: Text('Concierge Request')),
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
              controller: _descController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _requestTask,
              child: _loading ? CircularProgressIndicator() : Text('Request Concierge Task'),
            ),
            if (_taskId != null) ...[
              SizedBox(height: 16),
              Text('Task ID: $_taskId'),
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
