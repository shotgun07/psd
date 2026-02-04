import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oblns/features/orders/domain/order_repository.dart';
import 'package:oblns/features/orders/infrastructure/appwrite_order_repository.dart';
import 'package:oblns/features/chat/domain/chat_repository.dart';
import 'package:oblns/features/chat/infrastructure/appwrite_chat_repository.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';

// Wallet provider is defined near the implementation to avoid duplicate providers.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return AppwriteOrderRepository(
    ref.watch(appwriteDatabasesProvider),
    ref.watch(appwriteRealtimeProvider),
    ref.watch(appwriteFunctionsProvider),
  );
});


final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return AppwriteChatRepository(
    ref.watch(appwriteDatabasesProvider),
    ref.watch(appwriteRealtimeProvider),
  );
});
