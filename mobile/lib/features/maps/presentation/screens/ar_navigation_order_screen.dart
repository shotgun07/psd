import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../modules/logistics/ar_navigation/ar_navigation_service.dart';

class ArNavigationOrderScreen extends StatefulWidget {
  const ArNavigationOrderScreen({super.key});

  @override
  State<ArNavigationOrderScreen> createState() => _ArNavigationOrderScreenState();
}

class _ArNavigationOrderScreenState extends State<ArNavigationOrderScreen> {
  final _orderIdController = TextEditingController();
  final _service = ArNavigationService();
  final _mapController = MapController();
  List<ArInstruction> _instructions = [];
  String? _error;
  bool _loading = false;

  Future<void> _fetchRoute() async {
    setState(() {
      _loading = true;
      _error = null;
      _instructions = [];
    });
    try {
      final instructions = await _service.getArRoute(_orderIdController.text);
      setState(() => _instructions = instructions);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملاحة الطلب'),
        backgroundColor: const Color(0xFFe94560),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _orderIdController,
                    decoration: const InputDecoration(
                      labelText: 'معرف الطلب',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _fetchRoute(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _fetchRoute,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe94560)),
                  child: _loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('جلب المسار'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('خطأ: $_error', style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _instructions.isEmpty
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(32.8872, 13.1913),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _instructions.length,
                    itemBuilder: (context, i) {
                      final inst = _instructions[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFe94560),
                            child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(inst.step),
                          subtitle: inst.imageOverlay.isNotEmpty ? Text(inst.imageOverlay) : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
