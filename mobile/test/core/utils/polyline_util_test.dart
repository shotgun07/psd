import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:oblns/core/utils/polyline_util.dart';

void main() {
  group('PolylineUtil', () {
    test('Should encode and decode a simple path correctly', () {
      final points = [
        const LatLng(38.5, -120.2),
        const LatLng(40.7, -120.95),
        const LatLng(43.252, -126.453),
      ];

      final encoded = PolylineUtil.encode(points);
      expect(encoded.isNotEmpty, true);

      final decoded = PolylineUtil.decode(encoded);
      expect(decoded.length, points.length);

      // Precision loss check (1e5)
      expect(decoded[0].latitude, closeTo(38.5, 0.00001));
      expect(decoded[0].longitude, closeTo(-120.2, 0.00001));
    });

    test('Should handle empty list', () {
      final encoded = PolylineUtil.encode([]);
      expect(encoded, '');
      final decoded = PolylineUtil.decode('');
      expect(decoded, isEmpty);
    });
  });
}
