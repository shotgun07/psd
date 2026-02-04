import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:oblns/features/drivers/application/driver_location_service.dart';
import 'package:oblns/core/providers/app_providers.dart';

class TripTrackingScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripTrackingScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends ConsumerState<TripTrackingScreen> {
  GoogleMapController? _mapController;
  String _status = 'searching';
  StreamSubscription? _tripSubscription;
  StreamSubscription? _driverLocationSubscription;
  String? _driverId;
  DriverLocation? _driverLocation;
  final Set<Marker> _markers = {};

  int get _eta => _driverLocation != null && _driverLocation!.distance > 0
      ? (_driverLocation!.distance / 0.5 * 60)
            .round() // Assume 30 km/h avg speed
      : 5; // Default 5 minutes

  @override
  void initState() {
    super.initState();
    _startTrackingTrip();
  }

  void _startTrackingTrip() {
    // Watch the trip for status changes and driver assignment
    _tripSubscription = ref
        .read(orderRepositoryProvider)
        .watchOrder(widget.tripId)
        .listen((trip) {
          if (!mounted) return;

          setState(() {
            _status = trip.status;
            _driverId = trip.driverId;
          });

          // If driver assigned, start watching driver location
          if (_driverId != null && _driverLocationSubscription == null) {
            _startTrackingDriver(_driverId!);
          }
        });
  }

  void _startTrackingDriver(String driverId) {
    final locationService = ref.read(driverLocationServiceProvider);

    _driverLocationSubscription = locationService
        .watchDriverLocation(driverId)
        .listen((location) {
          if (!mounted || location == null) return;

          setState(() {
            _driverLocation = location;
            _updateDriverMarker(location);
          });

          // Update camera to show driver
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(location.latitude, location.longitude),
            ),
          );
        });
  }

  void _updateDriverMarker(DriverLocation location) {
    _markers.removeWhere((marker) => marker.markerId.value == 'driver');

    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(location.latitude, location.longitude),
        rotation: location.heading ?? 0,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'السائق',
          snippet: '${location.speed?.toStringAsFixed(0) ?? 0} كم/س',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(32.8872, 13.1913),
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),

          // Status Panel
          _buildStatusPanel(),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
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
            if (_status == 'searching') _buildSearchingState(),
            if (_status == 'assigned') _buildAssignedState(),
            if (_status == 'arriving') _buildArrivingState(),
            if (_status == 'in_progress') _buildInProgressState(),
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

  Widget _buildSearchingState() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFFe94560)),
        const SizedBox(height: 20),
        Text(
          'جاري البحث عن سائق...',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'سيتم العثور على أقرب سائق متاح',
          style: GoogleFonts.cairo(color: Colors.white60),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _showCancelDialog,
          child: Text(
            'إلغاء الطلب',
            style: GoogleFonts.cairo(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignedState() {
    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFe94560),
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أحمد السائق',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 • Toyota Corolla',
                        style: GoogleFonts.cairo(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'ABC 1234',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFe94560),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFe94560,
                    ).withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat, color: Color(0xFFe94560)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).round()),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('المسافة', '2.5 كم'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withAlpha((0.1 * 255).round()),
              ),
              _buildInfoItem('الوقت', '$_eta دقائق'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withAlpha((0.1 * 255).round()),
              ),
              _buildInfoItem('السعر', '22 LYD'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'السائق في الطريق إليك',
                style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrivingState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        ),
        const SizedBox(height: 16),
        Text(
          'السائق وصل!',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'يرجى التوجه إلى السيارة',
          style: GoogleFonts.cairo(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildInProgressState() {
    return Column(
      children: [
        Text(
          'في الطريق إلى وجهتك',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.05 * 255).round()),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('المتبقي', '1.2 كم'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withAlpha((0.1 * 255).round()),
              ),
              _buildInfoItem('الوصول', '3 دقائق'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shield),
            label: Text('مشاركة الموقع مع الوصي', style: GoogleFonts.cairo()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe94560),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'إلغاء الرحلة؟',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          'هل أنت متأكد من إلغاء هذه الرحلة؟',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لا', style: GoogleFonts.cairo(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'نعم، إلغاء',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    super.dispose();
  }
}
