import 'dart:convert';
import 'package:crypto/crypto.dart';

class HmacInterceptor {
  final String secret;

  HmacInterceptor(this.secret);

  String sign(String payload, String timestamp) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode('$timestamp$payload');
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  Map<String, String> getHeaders(String payload) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = sign(payload, timestamp);
    return {'X-OBLNS-Timestamp': timestamp, 'X-OBLNS-Signature': signature};
  }
}
