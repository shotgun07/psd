import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TripBlackboxService {
  final _storage = const FlutterSecureStorage();
  final _key = Key.fromSecureRandom(
    32,
  ); // In production, derive from user pin/biometrics
  final _iv = IV.fromLength(16);

  Future<void> saveEncryptedTrip(String tripId, String data) async {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(data, iv: _iv);
    await _storage.write(key: 'trip_$tripId', value: encrypted.base64);
  }

  Future<String?> getDecryptedTrip(String tripId) async {
    final base64Data = await _storage.read(key: 'trip_$tripId');
    if (base64Data == null) return null;

    final encrypter = Encrypter(AES(_key));
    return encrypter.decrypt64(base64Data, iv: _iv);
  }
}
