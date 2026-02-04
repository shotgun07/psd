import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:oblns/features/orders/application/order_notifier.dart';
import 'package:oblns/core/widgets/message_widgets.dart';
import 'package:oblns/core/utils/fare_calculator.dart';

class TripConfirmScreen extends ConsumerStatefulWidget {
  final String pickupAddress;
  final String destAddress;
  final LatLng pickupLatLng;
  final LatLng destLatLng;

  const TripConfirmScreen({
    super.key,
    required this.pickupAddress,
    required this.destAddress,
    required this.pickupLatLng,
    required this.destLatLng,
  });

  @override
  ConsumerState<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

class _TripConfirmScreenState extends ConsumerState<TripConfirmScreen> {
  int _selectedVehicle = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.pickupLatLng,
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: widget.pickupLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
              Marker(
                markerId: const MarkerId('dest'),
                position: widget.destLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: [widget.pickupLatLng, widget.destLatLng],
                color: const Color(0xFFe94560),
                width: 4,
              ),
            },
          ),

          // Bottom Sheet
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            _buildAddresses(),
            const SizedBox(height: 20),
            _buildVehicleOptions(),
            const SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3).fadeIn();
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildAddresses() {
    return Column(
      children: [
        _buildAddressRow(Icons.my_location, widget.pickupAddress, Colors.green),
        Container(
          margin: const EdgeInsets.only(left: 30),
          height: 20,
          width: 2,
          color: Colors.white.withAlpha((0.2 * 255).round()),
        ),
        _buildAddressRow(
          Icons.location_on,
          widget.destAddress,
          const Color(0xFFe94560),
        ),
      ],
    );
  }

  Widget _buildAddressRow(IconData icon, String address, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleOptions() {
    // Calculate base fare
    final baseFare = FareCalculator.calculateFare(
      pickupLat: widget.pickupLatLng.latitude,
      pickupLng: widget.pickupLatLng.longitude,
      dropoffLat: widget.destLatLng.latitude,
      dropoffLng: widget.destLatLng.longitude,
    );

    // Update vehicle prices based on multiplier
    final vehicles = [
      {
        'name': 'عادي',
        'icon': Icons.directions_car,
        'price': baseFare, // 1.0x
        'time': '5 دقائق',
      },
      {
        'name': 'مريح',
        'icon': Icons.local_taxi,
        'price': baseFare * 1.3, // 1.3x
        'time': '3 دقائق',
      },
      {
        'name': 'فاخر',
        'icon': Icons.airport_shuttle,
        'price': baseFare * 1.8, // 1.8x
        'time': '8 دقائق',
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final isSelected = _selectedVehicle == index;
          final price = vehicle['price'] as double;

          return GestureDetector(
            onTap: () => setState(() => _selectedVehicle = index),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFFe94560).withAlpha((0.2 * 255).round())
                    : Colors.white.withAlpha((0.05 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFe94560)
                      : Colors.white.withAlpha((0.1 * 255).round()),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    vehicle['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFFe94560)
                        : Colors.white60,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vehicle['name'] as String,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${price.toStringAsFixed(2)} LYD',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFe94560),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    // Calculate price again for the button (or verify it matches)
    final baseFare = FareCalculator.calculateFare(
      pickupLat: widget.pickupLatLng.latitude,
      pickupLng: widget.pickupLatLng.longitude,
      dropoffLat: widget.destLatLng.latitude,
      dropoffLng: widget.destLatLng.longitude,
    );

    final multipliers = [1.0, 1.3, 1.8];
    final price = baseFare * multipliers[_selectedVehicle];

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFe94560),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تأكيد - ${price.toStringAsFixed(2)} LYD',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmTrip() async {
    setState(() => _isLoading = true);

    // Create order request
    final orderRequest = OrderRequest(
      pickupLat: widget.pickupLatLng.latitude,
      pickupLng: widget.pickupLatLng.longitude,
      pickupAddress: widget.pickupAddress,
      destinationLat: widget.destLatLng.latitude,
      destinationLng: widget.destLatLng.longitude,
      destinationAddress: widget.destAddress,
    );

    // Call OrderNotifier to create the trip
    final success = await ref
        .read(orderProvider.notifier)
        .createOrder(orderRequest);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        MessageSnackBar.showSuccess(context, 'تم إنشاء الطلب بنجاح!');
        // Navigate to tracking screen
        Navigator.pushReplacementNamed(context, '/trip-tracking');
      } else {
        final errorMessage =
            ref.read(orderProvider).errorMessage ?? 'فشل في إنشاء الطلب';
        MessageSnackBar.showError(context, errorMessage);
      }
    }
  }
}
