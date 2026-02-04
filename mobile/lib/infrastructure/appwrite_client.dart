import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/config/env_config.dart';

/// Provider for the Appwrite [Client].
/// This is the core connection to the backend.
final appwriteClientProvider = Provider<Client>((ref) {
  Client client = Client();
  client
      .setEndpoint(EnvConfig.appwriteEndpoint)
      .setProject(EnvConfig.appwriteProjectId)
      .setSelfSigned(status: EnvConfig.selfSigned);
  return client;
});

/// Provider for the Appwrite [Account] service.
final appwriteAccountProvider = Provider<Account>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

/// Provider for the Appwrite [Databases] service.
final appwriteDatabasesProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

/// Provider for the Appwrite [Storage] service.
final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

/// Provider for the Appwrite [Realtime] service.
final appwriteRealtimeProvider = Provider<Realtime>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});

/// Provider for the Appwrite [Functions] service.
final appwriteFunctionsProvider = Provider<Functions>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Functions(client);
});
