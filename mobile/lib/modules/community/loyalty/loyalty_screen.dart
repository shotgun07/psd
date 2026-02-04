import 'package:flutter/material.dart';
import 'loyalty_service.dart';

class LoyaltyScreen extends StatefulWidget {
  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final LoyaltyService _service = LoyaltyService();
  final TextEditingController _userIdController = TextEditingController();
  LoyaltyStatus? _status;
  String? _error;
  bool _loading = false;

  Future<void> _fetchStatus() async {
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
    });
    try {
      final status = await _service.getLoyaltyStatus(_userIdController.text);
      setState(() {
        _status = status;
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
      appBar: AppBar(title: Text('Loyalty Status')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _fetchStatus,
              child: _loading ? CircularProgressIndicator() : Text('Get Loyalty Status'),
            ),
            if (_status != null) ...[
              SizedBox(height: 16),
              Text('Tier: ${_status!.tier}', style: TextStyle(fontSize: 18)),
              Text('Points: ${_status!.points}', style: TextStyle(fontSize: 18)),
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
