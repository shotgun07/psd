import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/theme.dart';
import 'package:oblns/core/providers/app_providers.dart';
import 'package:oblns/features/orders/presentation/screens/trip_tracking_screen.dart';
import 'package:latlong2/latlong.dart';

class OrderConfirmationScreen extends ConsumerStatefulWidget {
  final LatLng pickup;
  final LatLng dropoff;
  final String vehicleType;

  const OrderConfirmationScreen({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
  });

  @override
  ConsumerState<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends ConsumerState<OrderConfirmationScreen> {
  bool _isBooking = false;
  double _estimatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  Future<void> _calculatePrice() async {
    // In a real app, call the priceCalculator Appwrite function
    // For MVP, we'll do a simple local estimation
    final distance = const Distance().as(
      LengthUnit.Kilometer,
      widget.pickup,
      widget.dropoff,
    );
    setState(() {
      _estimatedPrice = 5.0 + (distance * 1.2); // Simple mock calculation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _InfoSection(
              title: 'Pickup Location',
              content:
                  'Selected point on map', // In production, reverse geocode this
              icon: Icons.location_on,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const _InfoSection(
              title: 'Dropoff Location',
              content: 'Selected point on map',
              icon: Icons.flag_rounded,
              iconColor: AppColors.secondary,
            ),
            const Divider(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Fare', style: TextStyle(fontSize: 18)),
                Text(
                  '${_estimatedPrice.toStringAsFixed(2)} LYD',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              child: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Find Driver'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final orderId = await orderRepo.createOrder(
        type: 'ride',
        pickupLat: widget.pickup.latitude,
        pickupLng: widget.pickup.longitude,
        pickupAddress: 'Map Location',
        dropoffLat: widget.dropoff.latitude,
        dropoffLng: widget.dropoff.longitude,
        dropoffAddress: 'Map Location',
        totalPrice: _estimatedPrice,
        paymentMethod: 'cash',
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripTrackingScreen(tripId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
