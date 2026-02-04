import 'package:oblns/core/models/transaction_model.dart';

abstract class WalletRepository {
  Future<double> getBalance();
  Future<List<TransactionModel>> getTransactionHistory();
  Future<void> addFunds(double amount, String paymentMethodId);
  Future<String> getCurrency();
  Future<void> setCurrency(String currency);
}
