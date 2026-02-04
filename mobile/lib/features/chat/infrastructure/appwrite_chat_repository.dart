import 'package:appwrite/appwrite.dart';
import 'package:oblns/features/chat/domain/chat_repository.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';

class AppwriteChatRepository implements ChatRepository {
  final Databases _databases;
  final Realtime _realtime;
  final String _databaseId = 'oblns';
  final String _collectionId = 'messages';

  AppwriteChatRepository(this._databases, this._realtime);

  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  @override
  Future<void> sendMessage(String chatId, String message) async {
    await _dbWrapper.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: ID.unique(),
      data: {
        'chat_id': chatId,
        'sender_id': 'current_user_id',
        'text': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Stream<Map<String, dynamic>> watchMessages(String chatId) {
    final subscription = _realtime.subscribe([
      'databases.$_databaseId.collections.$_collectionId.documents',
    ]);
    return subscription.stream
        .where((e) => (e.payload['chat_id']?.toString() ?? '') == chatId)
        .map((e) => Map<String, dynamic>.from(e.payload as Map));
  }
}
