import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/theme.dart';
import 'package:oblns/features/maps/presentation/widgets/animated_marker.dart';
import 'package:oblns/features/maps/application/offline_map_service.dart';

class LocationService {
  // Adaptive Sampling logic as per technical document
  static Duration getSamplingInterval(double speedKph, double batteryLevel) {
    if (batteryLevel < 0.15) return const Duration(seconds: 60);
    if (speedKph > 50) return const Duration(seconds: 1);
    if (speedKph > 10) return const Duration(seconds: 3);
    return const Duration(seconds: 10);
  }
}

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  LatLng _pickup = const LatLng(32.8872, 13.1913); // Default Tripoli
  LatLng _dropoff = const LatLng(32.8251, 13.1689);
  bool _selectingPickup = true;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book your ride')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickup,
              initialZoom: 13,
              onTap: (tapPosition, point) {
                if (_isSearching) return;
                setState(() {
                  if (_selectingPickup) {
                    _pickup = point;
                  } else {
                    _dropoff = point;
                  }
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.oblns.app',
                tileProvider: ref.watch(offlineMapServiceProvider).tileProvider,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickup,
                    width: 40,
                    height: 40,
                    child: const AnimatedMarker(
                      point: LatLng(0, 0), // Point handled by Marker wrapper
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  Marker(
                    point: _dropoff,
                    width: 40,
                    height: 40,
                    child: const AnimatedMarker(
                      point: LatLng(0, 0),
                      child: Icon(
                        Icons.flag_rounded,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!_isSearching)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _LocationButton(
                            label: 'Pickup',
                            isActive: _selectingPickup,
                            onPressed: () =>
                                setState(() => _selectingPickup = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LocationButton(
                            label: 'Dropoff',
                            isActive: !_selectingPickup,
                            onPressed: () =>
                                setState(() => _selectingPickup = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() => _isSearching = true),
                      child: const Text('Confirm Locations'),
                    ),
                  ],
                ),
              ),
            ),
          if (_isSearching) _buildSearchingOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _RadarAnimation(),
            const SizedBox(height: 48),
            const Text(
              'Searching for best driver...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scanning Tripoli Central Zone',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppColors.primary,
            ),
            const SizedBox(height: 64),
            TextButton(
              onPressed: () => setState(() => _isSearching = false),
              child: const Text(
                'CANCEL REQUEST',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarAnimation extends StatefulWidget {
  const _RadarAnimation();
  @override
  State<_RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<_RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...List.generate(4, (index) {
                final progress = (_controller.value + index / 4) % 1;
                return Container(
                  width: 250 * progress,
                  height: 250 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 1 - progress),
                      width: 1.5,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.1 * (1 - progress),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              }),
              const CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.gps_fixed_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _LocationButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
