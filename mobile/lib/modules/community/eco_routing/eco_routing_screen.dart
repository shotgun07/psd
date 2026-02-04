import 'package:flutter/material.dart';
import 'eco_routing_service.dart';

class EcoRoutingScreen extends StatefulWidget {
  @override
  _EcoRoutingScreenState createState() => _EcoRoutingScreenState();
}

class _EcoRoutingScreenState extends State<EcoRoutingScreen> {
  final EcoRoutingService _service = EcoRoutingService();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  EcoRouteResult? _result;
  String? _error;
  bool _loading = false;

  Future<void> _getRoute() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.getEcoRoute(
        _fromController.text,
        _toController.text,
      );
      setState(() {
        _result = result;
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
      appBar: AppBar(title: Text('Eco Routing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fromController,
              decoration: InputDecoration(labelText: 'From'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _toController,
              decoration: InputDecoration(labelText: 'To'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _getRoute,
              child: _loading ? CircularProgressIndicator() : Text('Get Eco Route'),
            ),
            if (_result != null) ...[
              SizedBox(height: 16),
              Text('Distance: ${_result!.distance} km'),
              Text('Carbon Saved: ${_result!.carbonSaved} kg'),
              Text('Reward Points: ${_result!.rewardPoints}'),
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
