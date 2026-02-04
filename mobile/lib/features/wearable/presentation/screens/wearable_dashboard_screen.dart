import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WearableDashboardScreen extends ConsumerStatefulWidget {
  const WearableDashboardScreen({super.key});

  @override
  ConsumerState<WearableDashboardScreen> createState() => _WearableDashboardScreenState();
}

class _WearableDashboardScreenState extends ConsumerState<WearableDashboardScreen> {
  bool _isDriving = false;
  final double _heartRate = 72.0;
  final double _speed = 0.0;
  final int _alerts = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearable Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildVitalsGrid(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isDriving ? Icons.drive_eta : Icons.person,
              size: 32,
              color: _isDriving ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isDriving ? 'Driving Mode Active' : 'Standby Mode',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isDriving ? 'Monitoring vitals and driving behavior' : 'Ready for next trip',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isDriving,
              onChanged: (value) {
                setState(() {
                  _isDriving = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildVitalCard('Heart Rate', '${_heartRate.toInt()} BPM', Icons.favorite, Colors.red),
        _buildVitalCard('Speed', '${_speed.toInt()} km/h', Icons.speed, Colors.blue),
        _buildVitalCard('Fatigue Level', 'Low', Icons.visibility, Colors.green),
        _buildVitalCard('Alerts', '$_alerts', Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.emergency),
                label: const Text('SOS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message),
                label: const Text('Message'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on),
                label: const Text('Location'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Health Check'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                _buildAlertItem('High heart rate detected', '2 min ago', Colors.red),
                _buildAlertItem('Sudden braking detected', '5 min ago', Colors.orange),
                _buildAlertItem('Fatigue warning', '10 min ago', Colors.yellow),
                _buildAlertItem('Trip completed successfully', '15 min ago', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String message, String time, Color color) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.circle, color: color, size: 12),
        title: Text(message, style: const TextStyle(fontSize: 14)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
        dense: true,
      ),
    );
  }
}
