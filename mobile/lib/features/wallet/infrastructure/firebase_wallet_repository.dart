import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/transaction_model.dart';
import 'package:oblns/core/firebase_config.dart';

class FirebaseWalletRepository {
  final FirebaseFirestore _firestore;

  FirebaseWalletRepository(this._firestore);

  /// Get user wallet balance
  Future<double> getBalance(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return 0.0;

      return (doc.data()?['wallet_balance'] ?? 0.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Get wallet balance stream
  Stream<double> getBalanceStream(String userId) {
    return _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0.0;
          return (doc.data()?['wallet_balance'] ?? 0.0).toDouble();
        });
  }

  /// Add funds to wallet (atomic operation)
  Future<void> addFunds({
    required String userId,
    required double amount,
    required String description,
    String? paymentMethod,
  }) async {
    if (amount <= 0) {
      throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    }

    final batch = _firestore.batch();

    // Create transaction record
    final transactionRef = _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .doc();

    batch.set(transactionRef, {
      'user_id': userId,
      'amount': amount,
      'type': 'credit',
      'status': 'completed',
      'description': description,
      'payment_method': paymentMethod,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update user balance
    final userRef = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId);

    batch.update(userRef, {
      'wallet_balance': FieldValue.increment(amount),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Deduct funds from wallet (atomic operation)
  Future<void> deductFunds({
    required String userId,
    required double amount,
    required String description,
    String? tripId,
  }) async {
    if (amount <= 0) {
      throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    }

    // Check if user has sufficient balance
    final currentBalance = await getBalance(userId);
    if (currentBalance < amount) {
      throw Exception('الرصيد غير كافٍ');
    }

    final batch = _firestore.batch();

    // Create transaction record
    final transactionRef = _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .doc();

    batch.set(transactionRef, {
      'user_id': userId,
      'amount': -amount,
      'type': 'debit',
      'status': 'completed',
      'description': description,
      'order_id': tripId,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update user balance
    final userRef = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId);

    batch.update(userRef, {
      'wallet_balance': FieldValue.increment(-amount),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Process trip payment
  Future<void> processTripPayment({
    required String riderId,
    required String driverId,
    required String tripId,
    required double fare,
  }) async {
    final batch = _firestore.batch();

    // Deduct from rider
    final riderTransactionRef = _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .doc();

    batch.set(riderTransactionRef, {
      'user_id': riderId,
      'amount': -fare,
      'type': 'debit',
      'status': 'completed',
      'description': 'دفع رحلة',
      'order_id': tripId,
      'created_at': FieldValue.serverTimestamp(),
    });

    final riderRef = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(riderId);

    batch.update(riderRef, {
      'wallet_balance': FieldValue.increment(-fare),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Add to driver (with commission deduction)
    final commission = fare * 0.2; // 20% commission
    final driverEarning = fare - commission;

    final driverTransactionRef = _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .doc();

    batch.set(driverTransactionRef, {
      'user_id': driverId,
      'amount': driverEarning,
      'type': 'credit',
      'status': 'completed',
      'description': 'أرباح رحلة',
      'order_id': tripId,
      'commission': commission,
      'created_at': FieldValue.serverTimestamp(),
    });

    final driverRef = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(driverId);

    batch.update(driverRef, {
      'wallet_balance': FieldValue.increment(driverEarning),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Get transaction history
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return TransactionModel(
              id: doc.id,
              userId: data['user_id'] ?? '',
              amount: (data['amount'] ?? 0.0).toDouble(),
              type: data['type'] ?? 'debit',
              orderId: data['order_id'],
              status: data['status'] ?? 'completed',
              createdAt: (data['created_at'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }

  /// Get transaction statistics
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    final snapshot = await _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .where('user_id', isEqualTo: userId)
        .get();

    double totalCredit = 0;
    double totalDebit = 0;
    int transactionCount = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      final amount = (doc.data()['amount'] ?? 0.0).toDouble();
      if (amount > 0) {
        totalCredit += amount;
      } else {
        totalDebit += amount.abs();
      }
    }

    return {
      'total_credit': totalCredit,
      'total_debit': totalDebit,
      'transaction_count': transactionCount,
      'current_balance': await getBalance(userId),
    };
  }

  /// Withdraw funds
  Future<void> withdrawFunds({
    required String userId,
    required double amount,
    required String bankAccount,
  }) async {
    if (amount <= 0) {
      throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    }

    final currentBalance = await getBalance(userId);
    if (currentBalance < amount) {
      throw Exception('الرصيد غير كافٍ');
    }

    final batch = _firestore.batch();

    // Create withdrawal transaction
    final transactionRef = _firestore
        .collection(FirebaseConfig.transactionsCollection)
        .doc();

    batch.set(transactionRef, {
      'user_id': userId,
      'amount': -amount,
      'type': 'withdrawal',
      'status': 'pending',
      'description': 'سحب رصيد',
      'bank_account': bankAccount,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update user balance
    final userRef = _firestore
        .collection(FirebaseConfig.usersCollection)
        .doc(userId);

    batch.update(userRef, {
      'wallet_balance': FieldValue.increment(-amount),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final firebaseWalletRepositoryProvider = Provider<FirebaseWalletRepository>((
  ref,
) {
  return FirebaseWalletRepository(ref.watch(firestoreProvider));
});
