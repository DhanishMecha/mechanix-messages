import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';

abstract class MessageRepository {
  Future<List<ConversationEntity>> getConversations({
    ConversationFilter filter = ConversationFilter.all,
    String query = '',
    int limit = Constants.pageSize,
    int offset = 0,
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
    int limit = Constants.pageSize,
    int offset = 0,
  });
}
