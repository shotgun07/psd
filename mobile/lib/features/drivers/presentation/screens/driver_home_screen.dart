import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oblns/core/widgets/glass_container.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:oblns/features/drivers/application/driver_notifier.dart';
import 'package:oblns/features/drivers/application/driver_location_service.dart';
import 'package:oblns/core/widgets/message_widgets.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  // ignore: unused_field
  Position? _currentPosition;
  bool _isOnline = false;
  // ignore: unused_field
  final bool _hasActiveTrip = false;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(32.8872, 13.1913),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              // ignore: deprecated_member_use
              controller.setMapStyle(_darkMapStyle);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildMenuButton(), _buildEarningsCard()],
              ),
            ),
          ),

          // Bottom Panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 15,
      child: const Icon(Icons.menu, color: Colors.white),
    );
  }

  Widget _buildEarningsCard() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 20,
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أرباح اليوم',
                style: GoogleFonts.cairo(color: Colors.white60, fontSize: 10),
              ),
              Text(
                '125.50 LYD',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            _buildOnlineToggle(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 10),
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

  Widget _buildOnlineToggle() {
    return GestureDetector(
      onTap: _toggleOnlineStatus,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isOnline
                ? [const Color(0xFF4CAF50), const Color(0xFF8BC34A)]
                : [const Color(0xFFe94560), const Color(0xFFff6b9d)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isOnline ? Colors.green : const Color(0xFFe94560))
                  .withAlpha((0.4 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOnline ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              _isOnline ? 'متصل - استلام الطلبات' : 'اضغط للاتصال',
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('الرحلات', '12', Icons.directions_car)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('التقييم', '4.8', Icons.star)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('الساعات', '6.5', Icons.access_time)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.1 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFe94560), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleOnlineStatus() async {
    final newStatus = !_isOnline;

    final success = await ref
        .read(driverProvider.notifier)
        .setOnlineStatus(newStatus);

    if (!success) {
      if (mounted) {
        MessageSnackBar.showError(context, 'فشل في تحديث الحالة');
      }
      return;
    }

    setState(() => _isOnline = newStatus);

    final locationService = ref.read(driverLocationServiceProvider);
    if (newStatus) {
      await locationService.startTracking('current_driver_id');
      if (mounted) {
        MessageSnackBar.showSuccess(context, 'أنت الآن متصل');
      }
    } else {
      await locationService.stopTracking();
      if (mounted) {
        MessageSnackBar.showSuccess(context, 'تم قطع الاتصال');
      }
    }
  }

  final String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]}
]
''';
}
