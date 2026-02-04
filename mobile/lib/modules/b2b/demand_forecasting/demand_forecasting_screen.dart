import 'package:flutter/material.dart';
import 'demand_forecasting_service.dart';

class DemandForecastingScreen extends StatefulWidget {
  @override
  _DemandForecastingScreenState createState() => _DemandForecastingScreenState();
}

class _DemandForecastingScreenState extends State<DemandForecastingScreen> {
  final DemandForecastingService _service = DemandForecastingService();
  final TextEditingController _merchantIdController = TextEditingController();
  DemandForecast? _forecast;
  String? _error;
  bool _loading = false;

  Future<void> _getForecast() async {
    setState(() {
      _loading = true;
      _error = null;
      _forecast = null;
    });
    try {
      final forecast = await _service.getForecast(_merchantIdController.text);
      setState(() {
        _forecast = forecast;
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
      appBar: AppBar(title: Text('Demand Forecasting')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _merchantIdController,
              decoration: InputDecoration(labelText: 'Merchant ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _getForecast,
              child: _loading ? CircularProgressIndicator() : Text('Get Forecast'),
            ),
            if (_forecast != null) ...[
              SizedBox(height: 16),
              Text('Predicted Orders: ${_forecast!.predictedOrders}'),
              Text('Trend: ${_forecast!.trend}'),
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
