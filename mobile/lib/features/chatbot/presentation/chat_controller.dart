import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';

class ChatNotifier extends ChangeNotifier {
  final ChatRepository _repository;
  List<ChatMessage> messages = [];
  bool isLoading = false;

  ChatNotifier(this._repository);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    isLoading = true;
    notifyListeners();

    try {
      final history = messages
          .where((m) => m != userMessage)
          .take(10)
          .map((m) => m.toJson())
          .toList();

      final responseText = await _repository.sendMessage(text, history);

      final aiMessage = ChatMessage(
        content: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(aiMessage);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      final errorMessage = ChatMessage(
        content: "Error: Unable to get response. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(errorMessage);
      notifyListeners();
    }
  }
}

final chatNotifierProvider = Provider<ChatNotifier>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});
