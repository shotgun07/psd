import 'package:flutter/material.dart';
import 'designated_driver_service.dart';

class DesignatedDriverScreen extends StatefulWidget {
  const DesignatedDriverScreen({super.key});

  @override
  State<DesignatedDriverScreen> createState() => _DesignatedDriverScreenState();
}

class _DesignatedDriverScreenState extends State<DesignatedDriverScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _loading = false;
  String? _error;

  Future<void> _bookDriver() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = DesignatedDriverService();
      await service.bookDesignatedDriver(
        _userIdController.text,
        _vehicleIdController.text,
        _selectedDateTime ?? DateTime.now(),
      );
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حجز السائق بنجاح!')));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز سائق خاص لسيارتك')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vehicleIdController,
              decoration: const InputDecoration(
                labelText: 'معرف السيارة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateTime,
                    child: Text(
                      _selectedDateTime == null
                          ? 'اختر الوقت'
                          : _selectedDateTime.toString(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _bookDriver,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('حجز السائق'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
