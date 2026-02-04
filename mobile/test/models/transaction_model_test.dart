import 'package:flutter_test/flutter_test.dart';
import 'package:oblns/core/models/transaction_model.dart';

void main() {
  group('TransactionModel Tests', () {
    final testDate = DateTime(2023, 10, 1, 12, 0, 0);
    final testTransaction = TransactionModel(
      id: 'txn1',
      userId: 'user1',
      amount: 50.0,
      type: 'credit',
      orderId: 'order1',
      status: 'completed',
      description: 'Payment for ride',
      createdAt: testDate,
    );

    test('TransactionModel supports value equality', () {
      final txn1 = TransactionModel(
        id: 'txn1',
        userId: 'user1',
        amount: 50.0,
        type: 'credit',
        status: 'completed',
        createdAt: testDate,
      );
      final txn2 = TransactionModel(
        id: 'txn1',
        userId: 'user1',
        amount: 50.0,
        type: 'credit',
        status: 'completed',
        createdAt: testDate,
      );
      expect(txn1, equals(txn2));
    });

    test('TransactionModel fromJson and toJson work correctly', () {
      const json = {
        'id': 'txn1',
        'user_id': 'user1',
        'amount': 50.0,
        'type': 'credit',
        'order_id': 'order1',
        'status': 'completed',
        'description': 'Payment for ride',
        'created_at': '2023-10-01T12:00:00.000',
      };

      final transaction = TransactionModel.fromJson(json);
      expect(transaction.id, 'txn1');
      expect(transaction.userId, 'user1');
      expect(transaction.amount, 50.0);
      expect(transaction.type, 'credit');
      expect(transaction.orderId, 'order1');
      expect(transaction.status, 'completed');
      expect(transaction.description, 'Payment for ride');
      expect(transaction.createdAt, testDate);
    });

    test('TransactionModel handles missing optional fields in JSON', () {
      const json = {
        'id': 'txn1',
        'user_id': 'user1',
        'amount': 50.0,
        'type': 'debit',
        'status': 'pending',
        'created_at': '2023-10-01T12:00:00.000',
      };

      final transaction = TransactionModel.fromJson(json);
      expect(transaction.orderId, isNull);
      expect(transaction.description, isNull);
    });

    test('TransactionModel copyWith works correctly', () {
      final updatedTxn = testTransaction.copyWith(
        status: 'failed',
        description: 'Updated description',
      );
      expect(updatedTxn.status, 'failed');
      expect(updatedTxn.description, 'Updated description');
      expect(updatedTxn.id, testTransaction.id);
      expect(updatedTxn.amount, testTransaction.amount);
    });

    test('TransactionModel throws error for invalid JSON', () {
      const invalidJson = {
        'user_id': 'user1',
        'amount': 50.0,
        'type': 'credit',
        'status': 'completed',
        'created_at': '2023-10-01T12:00:00.000',
        // missing id
      };

      expect(() => TransactionModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });
  });
}