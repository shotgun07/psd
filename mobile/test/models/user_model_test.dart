import 'package:flutter_test/flutter_test.dart';
import 'package:oblns/core/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    const testUser = UserModel(
      id: '1',
      name: 'Test User',
      phone: '+218911234567',
      email: 'test@example.com',
      walletBalance: 100.0,
      role: 'client',
      rating: 4.5,
      kycStatus: 'verified',
      profileImageUrl: 'https://example.com/image.jpg',
    );

    test('UserModel supports value equality', () {
      const user1 = UserModel(
        id: '1',
        name: 'Test User',
        phone: '+218911234567',
      );
      const user2 = UserModel(
        id: '1',
        name: 'Test User',
        phone: '+218911234567',
      );
      expect(user1, equals(user2));
    });

    test('UserModel has correct default values', () {
      const user = UserModel(
        id: '1',
        name: 'Test User',
        phone: '+218911234567',
      );
      expect(user.walletBalance, 0.0);
      expect(user.role, 'client');
      expect(user.rating, 5.0);
      expect(user.kycStatus, 'pending');
      expect(user.email, isNull);
      expect(user.profileImageUrl, isNull);
    });

    test('UserModel fromJson and toJson work correctly', () {
      const json = {
        'id': '1',
        'name': 'Test User',
        'phone': '+218911234567',
        'email': 'test@example.com',
        'wallet_balance': 100.0,
        'role': 'client',
        'rating': 4.5,
        'kyc_status': 'verified',
        'profile_image_url': 'https://example.com/image.jpg',
      };

      final user = UserModel.fromJson(json);
      expect(user, equals(testUser));
      expect(user.toJson(), equals(json));
    });

    test('UserModel handles missing optional fields in JSON', () {
      const json = {
        'id': '1',
        'name': 'Test User',
        'phone': '+218911234567',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, '1');
      expect(user.name, 'Test User');
      expect(user.phone, '+218911234567');
      expect(user.walletBalance, 0.0);
      expect(user.role, 'client');
      expect(user.rating, 5.0);
      expect(user.kycStatus, 'pending');
      expect(user.email, isNull);
      expect(user.profileImageUrl, isNull);
    });

    test('UserModel copyWith works correctly', () {
      final updatedUser = testUser.copyWith(
        name: 'Updated Name',
        walletBalance: 200.0,
      );
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.walletBalance, 200.0);
      expect(updatedUser.id, testUser.id);
      expect(updatedUser.phone, testUser.phone);
    });

    test('UserModel throws error for invalid JSON', () {
      const invalidJson = {
        'name': 'Test User',
        'phone': '+218911234567',
        // missing id
      };

      expect(() => UserModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });
  });
}
