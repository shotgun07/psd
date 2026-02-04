import 'package:flutter/material.dart';
import 'biometric_onboarding_service.dart';

class BiometricOnboardingScreen extends StatefulWidget {
  @override
  _BiometricOnboardingScreenState createState() => _BiometricOnboardingScreenState();
}

class _BiometricOnboardingScreenState extends State<BiometricOnboardingScreen> {
  final BiometricOnboardingService _service = BiometricOnboardingService();
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _biometricDataController = TextEditingController();
  BiometricOnboardingResult? _result;
  String? _error;
  bool _loading = false;

  Future<void> _onboardDriver() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.onboardDriver(
        _driverIdController.text,
        _biometricDataController.text,
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
      appBar: AppBar(title: Text('Biometric Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _driverIdController,
              decoration: InputDecoration(labelText: 'Driver ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _biometricDataController,
              decoration: InputDecoration(labelText: 'Biometric Data (base64)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _onboardDriver,
              child: _loading ? CircularProgressIndicator() : Text('Onboard Driver'),
            ),
            if (_result != null) ...[
              SizedBox(height: 16),
              Text('Success: ${_result!.success}'),
              Text('Message: ${_result!.message}'),
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
