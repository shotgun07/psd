import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/services/iot_service.dart';

class IotDashboardScreen extends ConsumerStatefulWidget {
  const IotDashboardScreen({super.key});

  @override
  ConsumerState<IotDashboardScreen> createState() => _IotDashboardScreenState();
}

class _IotDashboardScreenState extends ConsumerState<IotDashboardScreen> {
  final IoTService _iotService = IoTService();
  bool _isConnected = false;
  final Map<String, dynamic> _sensorData = {};
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectToIoT();
  }

  Future<void> _connectToIoT() async {
    try {
      await _iotService.connect();
      setState(() {
        _isConnected = true;
      });
      _subscribeToTopics();
      _addMessage('Connected to IoT network');
    } catch (e) {
      _addMessage('Failed to connect: $e');
    }
  }

  void _subscribeToTopics() {
    _iotService.subscribeToTopic('sensors/temperature', (message) {
      setState(() {
        _sensorData['temperature'] = message;
      });
      _addMessage('Temperature: $message°C');
    });

    _iotService.subscribeToTopic('sensors/humidity', (message) {
      setState(() {
        _sensorData['humidity'] = message;
      });
      _addMessage('Humidity: $message%');
    });

    _iotService.subscribeToTopic('sensors/location', (message) {
      setState(() {
        _sensorData['location'] = message;
      });
      _addMessage('Location update: $message');
    });

    _iotService.subscribeToTopic('vehicles/status', (message) {
      setState(() {
        _sensorData['vehicle_status'] = message;
      });
      _addMessage('Vehicle status: $message');
    });
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_messages.length > 50) {
        _messages.removeAt(0);
      }
    });
  }

  void _sendCommand(String topic, String message) {
    _iotService.publishMessage(topic, message);
    _addMessage('Sent to $topic: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _isConnected ? _disconnect : _connectToIoT,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          _buildSensorGrid(),
          _buildControlPanel(),
          Expanded(child: _buildMessageLog()),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _isConnected ? Colors.green[100] : Colors.red[100],
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.check_circle : Icons.error,
            color: _isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? 'Connected to IoT Network' : 'Disconnected',
            style: TextStyle(
              color: _isConnected ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSensorCard('Temperature', '${_sensorData['temperature'] ?? '--'}°C', Icons.thermostat),
          _buildSensorCard('Humidity', '${_sensorData['humidity'] ?? '--'}%', Icons.water_drop),
          _buildSensorCard('Location', _sensorData['location'] ?? '--', Icons.location_on),
          _buildSensorCard('Vehicle Status', _sensorData['vehicle_status'] ?? '--', Icons.directions_car),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Control Panel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendCommand('commands/lock_vehicle', 'lock'),
                  icon: const Icon(Icons.lock),
                  label: const Text('Lock Vehicle'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendCommand('commands/unlock_vehicle', 'unlock'),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unlock Vehicle'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendCommand('commands/start_engine', 'start'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Engine'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendCommand('commands/stop_engine', 'stop'),
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Engine'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageLog() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      _messages[_messages.length - 1 - index], // Reverse order
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _disconnect() {
    _iotService.disconnect();
    setState(() {
      _isConnected = false;
      _sensorData.clear();
    });
    _addMessage('Disconnected from IoT network');
  }

  @override
  void dispose() {
    _iotService.disconnect();
    super.dispose();
  }
}
