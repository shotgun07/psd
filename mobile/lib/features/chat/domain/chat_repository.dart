abstract class ChatRepository {
  Future<void> sendMessage(String chatId, String message);
  Stream<Map<String, dynamic>> watchMessages(String chatId);
}
