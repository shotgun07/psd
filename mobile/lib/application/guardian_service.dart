import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

enum GuardianStatus { safe, warning, danger }

class GuardianState {
  final GuardianStatus status;
  final String? message;
  final double deviationDistance;

  GuardianState({
    this.status = GuardianStatus.safe,
    this.message,
    this.deviationDistance = 0.0,
  });
}

class GuardianService extends Notifier<GuardianState> {
  final double _safeThresholdMeters = 200.0;
  final double _dangerThresholdMeters = 1000.0;
  List<LatLng> _activeRoute = [];
  Timer? _monitoringTimer;

  @override
  GuardianState build() {
    ref.onDispose(() {
      _monitoringTimer?.cancel();
    });
    return GuardianState();
  }

  void startMonitoring(List<LatLng> route) {
    _activeRoute = route;
    if (_activeRoute.isEmpty) return;

    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkDeviation();
    });
    state = GuardianState(status: GuardianStatus.safe);
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _activeRoute = [];
    state = GuardianState(status: GuardianStatus.safe);
  }

  Future<void> _checkDeviation() async {
    if (_activeRoute.isEmpty) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final currentLoc = LatLng(position.latitude, position.longitude);
      final deviation = _calculateMinDistance(currentLoc, _activeRoute);

      if (deviation > _dangerThresholdMeters) {
        state = GuardianState(
          status: GuardianStatus.danger,
          message: 'CRITICAL: Driver has deviated significantly ($deviation m)',
          deviationDistance: deviation,
        );
        _triggerEmergencyProtocol();
      } else if (deviation > _safeThresholdMeters) {
        state = GuardianState(
          status: GuardianStatus.warning,
          message: 'Warning: Slight route deviation detected ($deviation m)',
          deviationDistance: deviation,
        );
      } else {
        if (state.status != GuardianStatus.safe) {
          state = GuardianState(
            status: GuardianStatus.safe,
            deviationDistance: deviation,
          );
        }
      }
    } catch (e) {
      debugPrint('Guardian position error: $e');
    }
  }

  double _calculateMinDistance(LatLng point, List<LatLng> path) {
    double minDistance = double.infinity;
    const distance = Distance();

    for (final p in path) {
      final d = distance.as(LengthUnit.Meter, point, p);
      if (d < minDistance) {
        minDistance = d;
      }
    }
    return minDistance;
  }

  void _triggerEmergencyProtocol() {
    debugPrint("GUARDIAN: EMERGENCY PROTOCOL ACTIVATED - DEVIATION DETECTED");
  }
}

final guardianServiceProvider =
NotifierProvider<GuardianService, GuardianState>(() {
  return GuardianService();
});