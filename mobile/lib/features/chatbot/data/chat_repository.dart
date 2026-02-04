import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/appwrite_client.dart';

class ChatRepository {
  final Functions _functions;

  ChatRepository(this._functions);

  Future<String> sendMessage(
    String message,
    List<Map<String, dynamic>> history,
  ) async {
    try {
      final execution = await _functions.createExecution(
        functionId: 'aiChatbot',
        body: jsonEncode({'message': message, 'history': history}),
      );

      if (execution.status.toString() == 'completed') {
        final responseBody = jsonDecode(execution.responseBody);
        if (responseBody['success'] == true) {
          return responseBody['message'];
        } else {
          throw Exception(responseBody['message'] ?? 'Unknown error from AI');
        }
      } else {
        throw Exception('Function execution failed: ${execution.status}');
      }
    } catch (e) {
      throw Exception('Failed to communicate with AI: $e');
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final functions = ref.watch(appwriteFunctionsProvider);
  return ChatRepository(functions);
});
