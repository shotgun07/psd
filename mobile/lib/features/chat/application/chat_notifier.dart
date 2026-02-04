import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/features/chat/domain/chat_repository.dart';
import 'package:oblns/core/utils/error_messages.dart';
import 'package:oblns/core/observability/logging_config.dart';
import 'package:oblns/core/providers/app_providers.dart';

/// نموذج الرسالة - Message Model
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? fileUrl;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.fileUrl,
  });

  Message copyWith({bool? isRead}) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl,
      fileUrl: fileUrl,
    );
  }
}

/// حالات الدردشة - Chat States
enum ChatStatus { initial, loading, loaded, sending, error }

/// حالة الدردشة - Chat State
class ChatState {
  final ChatStatus status;
  final List<Message> messages;
  final String? chatId;
  final String? otherUserId;
  final String? otherUserName;
  final bool isTyping;
  final String? errorMessage;

  const ChatState({
    required this.status,
    this.messages = const [],
    this.chatId,
    this.otherUserId,
    this.otherUserName,
    this.isTyping = false,
    this.errorMessage,
  });

  factory ChatState.initial() => const ChatState(status: ChatStatus.initial);

  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? chatId,
    String? otherUserId,
    String? otherUserName,
    bool? isTyping,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatId: chatId ?? this.chatId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage,
    );
  }

  int get unreadCount => messages.where((m) => !m.isRead).length;
}

/// مدير حالة الدردشة - Chat State Manager
class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState.initial();

  ChatRepository get _repository => ref.watch(chatRepositoryProvider);

  /// تهيئة الدردشة - Initialize chat
  Future<void> initializeChat(
    String chatId,
    String otherUserId,
    String otherUserName,
  ) async {
    state = state.copyWith(
      status: ChatStatus.loading,
      chatId: chatId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
    );

    try {
      AppLogger.info('Initializing chat', {
        'chat_id': chatId,
        'other_user_id': otherUserId,
      });

      // Note: Watch messages stream
      // final messagesStream = _repository.watchMessages(chatId);

      state = state.copyWith(status: ChatStatus.loaded);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize chat', e, stackTrace);
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
    }
  }

  /// إرسال رسالة نصية - Send text message
  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return false;
    }

    if (state.chatId == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'لم يتم تهيئة الدردشة',
      );
      return false;
    }

    state = state.copyWith(status: ChatStatus.sending);

    try {
      AppLogger.info('Sending message', {
        'chat_id': state.chatId,
        'message_length': message.length,
      });

      await _repository.sendMessage(state.chatId!, message);

      state = state.copyWith(status: ChatStatus.loaded);

      AppLogger.analytics('message_sent', {
        'chat_id': state.chatId,
        'message_type': 'text',
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send message', e, stackTrace);
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// إرسال صورة - Send image
  Future<bool> sendImage(String imagePath) async {
    if (state.chatId == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'لم يتم تهيئة الدردشة',
      );
      return false;
    }

    state = state.copyWith(status: ChatStatus.sending);

    try {
      AppLogger.info('Sending image', {
        'chat_id': state.chatId,
        'image_path': imagePath,
      });

      // Note: This requires implementing sendImage in ChatRepository
      // await _repository.sendImage(state.chatId!, imagePath);

      state = state.copyWith(status: ChatStatus.loaded);

      AppLogger.analytics('message_sent', {
        'chat_id': state.chatId,
        'message_type': 'image',
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send image', e, stackTrace);
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// إرسال ملف - Send file
  Future<bool> sendFile(String filePath) async {
    if (state.chatId == null) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'لم يتم تهيئة الدردشة',
      );
      return false;
    }

    state = state.copyWith(status: ChatStatus.sending);

    try {
      AppLogger.info('Sending file', {
        'chat_id': state.chatId,
        'file_path': filePath,
      });

      // Note: This requires implementing sendFile in ChatRepository
      // await _repository.sendFile(state.chatId!, filePath);

      state = state.copyWith(status: ChatStatus.loaded);

      AppLogger.analytics('message_sent', {
        'chat_id': state.chatId,
        'message_type': 'file',
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send file', e, stackTrace);
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// تحديث الرسائل - Update messages
  void updateMessages(List<Message> messages) {
    state = state.copyWith(messages: messages);
    AppLogger.debug('Messages updated', {'count': messages.length});
  }

  /// إضافة رسالة جديدة - Add new message
  void addMessage(Message message) {
    final updatedMessages = [message, ...state.messages];
    state = state.copyWith(messages: updatedMessages);
  }

  /// تحديد حالة الكتابة - Set typing status
  void setTypingStatus(bool isTyping) {
    state = state.copyWith(isTyping: isTyping);
  }

  /// وضع علامة مقروء على الرسالة - Mark message as read
  Future<bool> markAsRead(String messageId) async {
    if (state.chatId == null) return false;

    try {
      // Note: This requires implementing markAsRead in ChatRepository
      // await _repository.markAsRead(state.chatId!, messageId);

      // Update local state
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark message as read', e, stackTrace);
      return false;
    }
  }

  /// وضع علامة مقروء على جميع الرسائل - Mark all messages as read
  Future<void> markAllAsRead() async {
    if (state.chatId == null) return;

    try {
      final unreadMessages = state.messages.where((m) => !m.isRead).toList();

      for (final message in unreadMessages) {
        await markAsRead(message.id);
      }

      AppLogger.info('All messages marked as read', {
        'chat_id': state.chatId,
        'count': unreadMessages.length,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark all as read', e, stackTrace);
    }
  }

  /// مسح الخطأ - Clear error
  void clearError() {
    if (state.status == ChatStatus.error) {
      state = state.copyWith(status: ChatStatus.loaded, errorMessage: null);
    }
  }

  /// إعادة تعيين الحالة - Reset state
  void reset() {
    state = ChatState.initial();
  }
}

/// مزود حالة الدردشة - Chat State Provider
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
