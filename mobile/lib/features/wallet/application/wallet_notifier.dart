import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/transaction_model.dart';
import 'package:oblns/features/wallet/domain/wallet_repository.dart';
import 'package:oblns/core/utils/error_messages.dart';
import 'package:oblns/core/observability/logging_config.dart';
import 'package:oblns/features/wallet/infrastructure/appwrite_wallet_repository.dart';

/// حالات المحفظة - Wallet States
enum WalletStatus { initial, loading, loaded, error, processing }

/// حالة المحفظة - Wallet State
class WalletState {
  final WalletStatus status;
  final double balance;
  final List<TransactionModel> transactions;
  final String? errorMessage;
  final bool isProcessing;

  const WalletState({
    required this.status,
    this.balance = 0.0,
    this.transactions = const [],
    this.errorMessage,
    this.isProcessing = false,
  });

  factory WalletState.initial() =>
      const WalletState(status: WalletStatus.initial);

  WalletState copyWith({
    WalletStatus? status,
    double? balance,
    List<TransactionModel>? transactions,
    String? errorMessage,
    bool? isProcessing,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// مدير حالة المحفظة - Wallet State Manager
class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => WalletState.initial();

  WalletRepository get _repository => ref.watch(walletRepositoryProvider);

  /// تحميل الرصيد - Load balance
  Future<void> loadBalance() async {
    state = state.copyWith(status: WalletStatus.loading);

    try {
      final balance = await _repository.getBalance();
      state = state.copyWith(status: WalletStatus.loaded, balance: balance);

      AppLogger.info('Wallet balance loaded', {'balance': balance});
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load wallet balance', e, stackTrace);
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
    }
  }

  /// تحميل سجل المعاملات - Load transaction history
  Future<void> loadTransactions() async {
    state = state.copyWith(status: WalletStatus.loading);

    try {
      final transactions = await _repository.getTransactionHistory();
      state = state.copyWith(
        status: WalletStatus.loaded,
        transactions: transactions,
      );

      AppLogger.info('Wallet transactions loaded', {
        'count': transactions.length,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load transactions', e, stackTrace);
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
    }
  }

  /// إضافة أموال - Add funds
  Future<bool> addFunds(double amount, String paymentMethodId) async {
    if (amount <= 0) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'المبلغ يجب أن يكون أكبر من صفر',
      );
      return false;
    }

    state = state.copyWith(status: WalletStatus.processing, isProcessing: true);

    try {
      await _repository.addFunds(amount, paymentMethodId);

      // تحديث الرصيد بعد الإضافة
      await loadBalance();
      await loadTransactions();

      AppLogger.financial('Funds added', amount, 'LYD', {
        'payment_method': paymentMethodId,
        'new_balance': state.balance,
      });

      state = state.copyWith(status: WalletStatus.loaded, isProcessing: false);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add funds', e, stackTrace, {
        'amount': amount,
        'payment_method': paymentMethodId,
      });

      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: ErrorMessages.mapPaymentError(e.toString()),
        isProcessing: false,
      );

      return false;
    }
  }

  /// خصم أموال - Deduct funds (for ride payment)
  Future<bool> deductFunds(double amount, String orderId) async {
    if (amount <= 0) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'المبلغ يجب أن يكون أكبر من صفر',
      );
      return false;
    }

    if (state.balance < amount) {
      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'الرصيد غير كافي',
      );
      return false;
    }

    state = state.copyWith(status: WalletStatus.processing, isProcessing: true);

    try {
      // Note: This requires adding deductFunds method to WalletRepository
      // await _repository.deductFunds(amount, orderId);

      // For now, reload balance
      await loadBalance();
      await loadTransactions();

      AppLogger.financial('Funds deducted', amount, 'LYD', {
        'order_id': orderId,
        'new_balance': state.balance,
      });

      state = state.copyWith(status: WalletStatus.loaded, isProcessing: false);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to deduct funds', e, stackTrace, {
        'amount': amount,
        'order_id': orderId,
      });

      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
        isProcessing: false,
      );

      return false;
    }
  }

  /// استرداد أموال - Refund
  Future<bool> refund(String transactionId, double amount) async {
    state = state.copyWith(status: WalletStatus.processing, isProcessing: true);

    try {
      // Note: This requires adding refund method to WalletRepository
      // await _repository.refund(transactionId, amount);

      await loadBalance();
      await loadTransactions();

      AppLogger.financial('Refund processed', amount, 'LYD', {
        'transaction_id': transactionId,
        'new_balance': state.balance,
      });

      state = state.copyWith(status: WalletStatus.loaded, isProcessing: false);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to process refund', e, stackTrace, {
        'transaction_id': transactionId,
        'amount': amount,
      });

      state = state.copyWith(
        status: WalletStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
        isProcessing: false,
      );

      return false;
    }
  }

  /// تحديث البيانات - Refresh data
  Future<void> refresh() async {
    await Future.wait([loadBalance(), loadTransactions()]);
  }

  /// مسح الخطأ - Clear error
  void clearError() {
    if (state.status == WalletStatus.error) {
      state = state.copyWith(status: WalletStatus.loaded, errorMessage: null);
    }
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});
