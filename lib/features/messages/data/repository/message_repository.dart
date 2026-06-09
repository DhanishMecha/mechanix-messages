import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';

abstract class MessageRepository {
  Future<List<ConversationEntity>> getConversations();

  Future<List<ConversationEntity>> getUnreadConversations();

  Future<ConversationEntity?> getConversationById(int id);

  Future<MessageEntity> insertMessage(
    String phoneNumber,
    String body,
    MessageDirection direction,
  );

  Future<void> markAllAsRead(int conversationId);
}
