import 'package:flutter/material.dart';
import 'white_label_api_service.dart';

class WhiteLabelBookingScreen extends StatefulWidget {
  @override
  _WhiteLabelBookingScreenState createState() => _WhiteLabelBookingScreenState();
}

class _WhiteLabelBookingScreenState extends State<WhiteLabelBookingScreen> {
  final WhiteLabelApiService _service = WhiteLabelApiService();
  final TextEditingController _businessIdController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _itemsController = TextEditingController();
  String? _bookingId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _bookDelivery() async {
    setState(() {
      _loading = true;
      _error = null;
      _bookingId = null;
      _status = null;
    });
    try {
      final items = _itemsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final resp = await _service.bookDelivery(
        _businessIdController.text,
        _fromController.text,
        _toController.text,
        items,
      );
      setState(() {
        _bookingId = resp.bookingId;
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
      appBar: AppBar(title: Text('White Label Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _businessIdController,
              decoration: InputDecoration(labelText: 'Business ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _fromController,
              decoration: InputDecoration(labelText: 'From'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _toController,
              decoration: InputDecoration(labelText: 'To'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemsController,
              decoration: InputDecoration(labelText: 'Items (comma separated)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _bookDelivery,
              child: _loading ? CircularProgressIndicator() : Text('Book Delivery'),
            ),
            if (_bookingId != null) ...[
              SizedBox(height: 16),
              Text('Booking ID: $_bookingId'),
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
