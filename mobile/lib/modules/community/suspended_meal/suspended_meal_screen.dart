import 'package:flutter/material.dart';
import 'suspended_meal_service.dart';

class SuspendedMealScreen extends StatefulWidget {
  @override
  _SuspendedMealScreenState createState() => _SuspendedMealScreenState();
}

class _SuspendedMealScreenState extends State<SuspendedMealScreen> {
  final SuspendedMealService _service = SuspendedMealService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _restaurantIdController = TextEditingController();
  String? _donationId;
  String? _status;
  String? _error;
  bool _loading = false;

  Future<void> _donateMeal() async {
    setState(() {
      _loading = true;
      _error = null;
      _donationId = null;
      _status = null;
    });
    try {
      final resp = await _service.donateMeal(
        _userIdController.text,
        _restaurantIdController.text,
      );
      setState(() {
        _donationId = resp.donationId;
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
      appBar: AppBar(title: Text('Donate Suspended Meal')),
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
              controller: _restaurantIdController,
              decoration: InputDecoration(labelText: 'Restaurant ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _donateMeal,
              child: _loading ? CircularProgressIndicator() : Text('Donate Meal'),
            ),
            if (_donationId != null) ...[
              SizedBox(height: 16),
              Text('Donation ID: $_donationId'),
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
