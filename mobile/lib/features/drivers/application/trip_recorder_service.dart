import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// TripRecorderService ("The Blackbox")
/// Records high-frequency trip data locally with encryption.
/// Used for accident reconstruction and dispute resolution.
class TripRecorderService {
  final List<Map<String, dynamic>> _buffer = [];
  final int _bufferSize = 50; // Write every 50 points

  // Symmetric Key for Blackbox (In prod, rotate this and store in SecureStorage)
  final _key = encrypt.Key.fromLength(32);
  final _iv = encrypt.IV.fromLength(16);
  late encrypt.Encrypter _encrypter;

  TripRecorderService() {
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  void recordPoint(LatLng point, double speed, double heading) {
    _buffer.add({
      'lat': point.latitude,
      'lng': point.longitude,
      'spd': speed,
      'hdg': heading,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });

    if (_buffer.length >= _bufferSize) {
      _flushBuffer();
    }
  }

  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty) return;

    final data = jsonEncode(_buffer);
    _buffer.clear();

    final encrypted = _encrypter.encrypt(data, iv: _iv);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/trip_blackbox_${DateTime.now().hour}.log');

    // Append encrypted line
    await file.writeAsString('${encrypted.base64}\n', mode: FileMode.append);
  }
}

final tripRecorderProvider = Provider<TripRecorderService>((ref) {
  return TripRecorderService();
});
