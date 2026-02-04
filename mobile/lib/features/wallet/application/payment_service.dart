import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentMethod { sadad, tadawul, cash, cards }

class PaymentService {
  Future<void> initiatePayment(
    String orderId,
    double amount,
    PaymentMethod method,
  ) async {
    switch (method) {
      case PaymentMethod.sadad:
        await _launchDeepLink('sadad://pay?id=$orderId&amount=$amount');
        break;
      case PaymentMethod.tadawul:
        await _launchDeepLink('tadawul://pay?id=$orderId&amount=$amount');
        break;
      default:
        // Standard flow
        break;
    }
  }

  Future<void> _launchDeepLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch payment app for $url');
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
