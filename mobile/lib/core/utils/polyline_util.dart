import 'package:latlong2/latlong.dart';

/// Utility class for Polyline optimization.
/// Implements standard algorithm (like Google's) to compress LatLng lists.
/// Reduces bandwidth usage significantly compared to JSON arrays.
class PolylineUtil {
  /// Encodes a list of [LatLng] points into a polyline string.
  static String encode(List<LatLng> points) {
    StringBuffer result = StringBuffer();
    int lastLat = 0;
    int lastLng = 0;

    for (final point in points) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      int dLat = lat - lastLat;
      int dLng = lng - lastLng;

      _encodeInt(dLat, result);
      _encodeInt(dLng, result);

      lastLat = lat;
      lastLng = lng;
    }
    return result.toString();
  }

  /// Decodes a polyline string into a list of [LatLng] points.
  static List<LatLng> decode(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  static void _encodeInt(int value, StringBuffer result) {
    int v = value < 0 ? ~(value << 1) : (value << 1);
    while (v >= 0x20) {
      result.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    result.writeCharCode(v + 63);
  }
}
