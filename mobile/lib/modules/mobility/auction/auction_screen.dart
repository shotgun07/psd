import 'package:flutter/material.dart';
import 'auction_service.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({Key? key}) : super(key: key);

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  List<DriverBid> _bids = [];
  bool _loading = false;
  String? _error;

  Future<void> _getBids() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = AuctionService();
      final bids = await service.postRouteAndCollectBids(
        _userIdController.text,
        _fromController.text,
        _toController.text,
      );
      setState(() {
        _bids = bids;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مزاد الرحلات العكسي')),
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
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'من',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'إلى',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _getBids,
              child: _loading ? const CircularProgressIndicator() : const Text('جمع عروض السائقين'),
            ),
            const SizedBox(height: 24),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: _bids.length,
                itemBuilder: (context, index) {
                  final bid = _bids[index];
                  return ListTile(
                    title: Text('سائق: ${bid.driverId}'),
                    subtitle: Text('السعر: ${bid.price.toStringAsFixed(2)} دينار'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
