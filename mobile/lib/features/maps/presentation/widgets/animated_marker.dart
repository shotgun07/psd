import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AnimatedMarker extends StatefulWidget {
  final LatLng point;
  final Widget child;
  final Duration duration;
  final double? rotation;

  const AnimatedMarker({
    super.key,
    required this.point,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.rotation,
  });

  @override
  State<AnimatedMarker> createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _prevRotation;
  late double _currentRotation;

  @override
  void initState() {
    super.initState();
    _prevRotation = widget.rotation ?? 0.0;
    _currentRotation = widget.rotation ?? 0.0;

    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant AnimatedMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotation != widget.rotation) {
      _prevRotation = oldWidget.rotation ?? 0.0;
      _currentRotation = widget.rotation ?? 0.0;

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: In flutter_map, Markers are positioned by the map.
    // This widget should return the child, but we might need to handle the LatLng interpolation
    // at the MarkerLayer level if we want true smooth movement on the map canvas.
    // However, since `Marker` takes a fixed `point`, we can't easily animate the position *inside* the Marker widget
    // unless we constantly rebuild the MarkerLayer with new points.
    //
    // A better approach for `flutter_map` is to use a Timer in the parent to interpolate the LatLng
    // passed to the Marker. But for this "AnimatedMarker" widget to work *inside* a Marker,
    // it can mainly animate rotation or internal content.
    //
    // To achieve true smooth movement (Item 12), we typically need to manage the LatLng implementation
    // in the State management layer (Riverpod) or a controller that interpolates updates
    // and feeds the MarkerLayer with 60fps updates.
    //
    // For now, let's implement the Rotation animation here, which is Self-Contained.

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rotation = Tween<double>(
          begin: _prevRotation,
          end: _currentRotation,
        ).evaluate(_controller);

        return Transform.rotate(angle: rotation, child: widget.child);
      },
      child: widget.child,
    );
  }
}
