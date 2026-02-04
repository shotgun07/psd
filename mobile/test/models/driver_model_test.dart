import 'package:flutter_test/flutter_test.dart';
import 'package:oblns/core/models/driver_model.dart';

void main() {
  group('DriverModel Tests', () {
    const testDriver = DriverModel(
      id: '1',
      userId: 'user1',
      isOnline: true,
      currentLat: 32.8872,
      currentLng: 13.1913,
      rating: 4.8,
      vehicleType: 'sedan',
      vehiclePlate: 'ABC123',
      vehicleDetails: 'Toyota Camry 2020',
      verificationStatus: 'verified',
    );

    test('DriverModel supports value equality', () {
      const driver1 = DriverModel(
        id: '1',
        userId: 'user1',
        isOnline: true,
      );
      const driver2 = DriverModel(
        id: '1',
        userId: 'user1',
        isOnline: true,
      );
      expect(driver1, equals(driver2));
    });

    test('DriverModel has correct default values', () {
      const driver = DriverModel(
        id: '1',
        userId: 'user1',
      );
      expect(driver.isOnline, false);
      expect(driver.rating, 5.0);
      expect(driver.verificationStatus, 'pending');
      expect(driver.currentLat, isNull);
      expect(driver.currentLng, isNull);
      expect(driver.vehicleType, isNull);
      expect(driver.vehiclePlate, isNull);
      expect(driver.vehicleDetails, isNull);
    });

    test('DriverModel fromJson and toJson work correctly', () {
      const json = {
        'id': '1',
        'userId': 'user1',
        'isOnline': true,
        'currentLat': 32.8872,
        'currentLng': 13.1913,
        'rating': 4.8,
        'vehicleType': 'sedan',
        'vehiclePlate': 'ABC123',
        'vehicleDetails': 'Toyota Camry 2020',
        'verificationStatus': 'verified',
      };

      final driver = DriverModel.fromJson(json);
      expect(driver, equals(testDriver));
      expect(driver.toJson(), equals(json));
    });

    test('DriverModel handles missing optional fields in JSON', () {
      const json = {
        'id': '1',
        'userId': 'user1',
      };

      final driver = DriverModel.fromJson(json);
      expect(driver.id, '1');
      expect(driver.userId, 'user1');
      expect(driver.isOnline, false);
      expect(driver.rating, 5.0);
      expect(driver.verificationStatus, 'pending');
      expect(driver.currentLat, isNull);
    });

    test('DriverModel copyWith works correctly', () {
      final updatedDriver = testDriver.copyWith(
        isOnline: false,
        rating: 4.9,
      );
      expect(updatedDriver.isOnline, false);
      expect(updatedDriver.rating, 4.9);
      expect(updatedDriver.id, testDriver.id);
      expect(updatedDriver.userId, testDriver.userId);
    });
  });
}