import 'package:flutter_test/flutter_test.dart';
import 'package:oblns/core/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('Should deserialize valid JSON correctly', () {
      final json = {
        'id': 'user123',
        'name': 'Test User',
        'phone': '+218911234567',
        'email': 'test@oblns.ly',
        'wallet_balance': 500.0,
        'role': 'driver',
        'kyc_status': 'approved',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user123');
      expect(user.name, 'Test User');
      expect(user.walletBalance, 500.0);
      expect(user.role, 'driver');
    });

    test('Should handle defaults when optional fields are missing', () {
      final json = {
        'id': 'user123',
        'name': 'New User',
        'phone': '+218911234567',
      };

      final user = UserModel.fromJson(json);

      expect(user.walletBalance, 0.0);
      expect(user.role, 'client');
      expect(user.kycStatus, 'pending');
      expect(user.email, null);
    });
  });
}
