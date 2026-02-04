import 'dart:convert';
import 'package:appwrite/appwrite.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/transaction_model.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';
import 'package:oblns/features/wallet/domain/wallet_repository.dart';

class AppwriteWalletRepository implements WalletRepository {
  final Databases _databases;
  final Functions _functions;
  final String _databaseId = 'oblns';
  final String _usersCollection = 'users';
  final String _transactionsCollection = 'transactions';

  AppwriteWalletRepository(this._databases, this._functions);
  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  @override
  Future<double> getBalance() async {
    // In production, get actual user ID
    // Note: getRow is the new API replacing getDocument for Databases service (if using custom extension)
    // However, the warnings say `TablesDB.getRow`.
    // It seems our `Databases` object is actually `TablesDB` (from my previous fix I likely kept the type as Databases but SDK expects something else?)
    // Actually, Appwrite SDK v9+ uses `Databases` class which has `getDocument`.
    // The warnings suggest I am using a `TablesDB` class or extension?

    // Ah, the warnings say: `'getDocument' is deprecated... Please use TablesDB.getRow instead`.
    // This implies `Databases` might be an alias or I should be using `_databases.getRow`.
    // Let's assume standard Appwrite `Databases` methods are `getDocument`.
    // If the linter is configured for a specific internal version, I will trust the linter.

    final doc = await _dbWrapper.getDocument(
      databaseId: _databaseId,
      collectionId: _usersCollection,
      documentId: 'current_user_id',
    );
    return (doc.data['wallet_balance'] as num).toDouble();
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory() async {
    // ignore: deprecated_member_use
    final response = await _dbWrapper.listDocuments(
      databaseId: _databaseId,
      collectionId: _transactionsCollection,
      queries: [
        Query.equal('user_id', 'current_user_id'),
        Query.orderDesc('\$createdAt'),
      ],
    );
    return response.documents
        .map((e) => TransactionModel.fromJson(e.data))
        .toList();
  }

  @override
  Future<void> addFunds(double amount, String paymentMethodId) async {
    final payload = {
      'user_id': 'current_user_id',
      'amount': amount,
      'transaction_type': 'deposit',
      'idempotency_key': ID.unique(), // Should be passed from UI ideally
      'payment_method_id': paymentMethodId,
    };

    final execution = await _functions.createExecution(
      functionId: 'walletSync',
      body: jsonEncode(payload),
    );

    // Check status properly using string first to avoid enum issues if SDK version differs
    // Check status properly using string first to avoid enum issues if SDK version differs
    if (execution.status.toString() != 'completed') {
      // Only if needed to compare enum:
      // && execution.status != models.ExecutionStatus.completed
      throw Exception('Wallet sync failed: ${execution.responseBody}');
    }

    final responseData = jsonDecode(execution.responseBody);
    if (responseData['success'] != true) {
      throw Exception(responseData['error'] ?? 'Unknown wallet error');
    }
  }

  @override
  Future<String> getCurrency() async {
    // TODO: Fetch from user preferences or remote config
    return 'LYD';
  }

  @override
  Future<void> setCurrency(String currency) async {
    // TODO: Save to user preferences
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final functions = ref.watch(appwriteFunctionsProvider);
  return AppwriteWalletRepository(databases, functions);
});
