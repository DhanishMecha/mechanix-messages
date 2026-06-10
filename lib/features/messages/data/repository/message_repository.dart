import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';

abstract class MessageRepository {
  Future<List<ConversationEntity>> getConversations({
    ConversationFilter filter,
    String query,
    int limit,
    int offset,
  });

  Future<ConversationEntity?> getConversationById(int id);

  Future<ConversationEntity> getOrCreateConversation(String phoneNumber);

  Future<MessageEntity> insertMessage(
    String phoneNumber,
    String body,
    MessageDirection direction,
  );

  Future<void> markAllAsRead(int conversationId);

  Future<List<MessageEntity>> getMessagesForConversation(
    int conversationId, {
    int limit,
    int offset,
  });

  Future<List<ContactEntity>> getContacts({
    String query,
    int limit,
    int offset,
  });
}
