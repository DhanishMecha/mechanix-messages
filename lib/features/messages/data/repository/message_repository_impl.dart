import 'package:mechanix_messages/core/services/objectbox_service.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/contact_model.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
import 'package:mechanix_messages/features/messages/data/models/phone_number_model.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';
import 'package:mechanix_messages/objectbox.g.dart';

class MessageRepositoryImpl implements MessageRepository {
  ObjectBoxService? _objectBox;

  MessageRepositoryImpl();

  Future<ObjectBoxService> _getBox() async {
    _objectBox ??= await ObjectBoxService.init();
    return _objectBox!;
  }

  @override
  Future<List<ConversationEntity>> getConversations() async {
    final boxService = await _getBox();
    final query = boxService.store
        .box<ConversationEntity>()
        .query()
        .order(ConversationEntity_.updatedAt, flags: Order.descending)
        .build();
    final conversations = query.find();
    query.close();
    return conversations;
  }

  @override
  Future<List<ConversationEntity>> getUnreadConversations() async {
    final conversations = await getConversations();
    return conversations
        .where((c) => c.messages.any((m) => m.readAt == null))
        .toList();
  }

  @override
  Future<ConversationEntity?> getConversationById(int id) async {
    final boxService = await _getBox();
    return boxService.store.box<ConversationEntity>().get(id);
  }

  @override
  Future<MessageEntity> insertMessage(
    String phoneNumber,
    String body,
    MessageDirection direction,
  ) async {
    final boxService = await _getBox();
    final conversationBox = boxService.store.box<ConversationEntity>();

    final query = conversationBox
        .query(ConversationEntity_.phoneNumber.equals(phoneNumber))
        .build();
    ConversationEntity? conversation = query.findFirst();
    query.close();

    final now = DateTime.now();
    if (conversation == null) {
      conversation = ConversationEntity(
        phoneNumber: phoneNumber,
        createdAt: now,
        updatedAt: now,
      );

      final phoneBox = boxService.store.box<PhoneNumberEntity>();
      final pQuery = phoneBox
          .query(PhoneNumberEntity_.number.equals(phoneNumber))
          .build();
      final phoneEntity = pQuery.findFirst();
      pQuery.close();

      if (phoneEntity != null) {
        conversation.phone.target = phoneEntity;
      } else {
        final contact = ContactEntity(name: phoneNumber);
        final phone = PhoneNumberEntity(number: phoneNumber)
          ..contact.target = contact;
        conversation.phone.target = phone;
      }
    } else {
      conversation.updatedAt = now;
    }

    final sender = direction == MessageDirection.incoming ? phoneNumber : 'me';
    final recipient = direction == MessageDirection.outgoing
        ? phoneNumber
        : 'me';

    final message = MessageEntity(
      sender: sender,
      recipient: recipient,
      body: body,
      direction: direction.index,
      status: MessageStatus.sent.index,
      createdAt: now,
    );

    message.conversation.target = conversation;
    conversation.messages.add(message);

    conversationBox.put(conversation);

    return message;
  }

  @override
  Future<void> markAllAsRead(int conversationId) async {
    final boxService = await _getBox();
    final conversationBox = boxService.store.box<ConversationEntity>();
    final conversation = conversationBox.get(conversationId);
    if (conversation == null) return;

    final now = DateTime.now();
    bool updatedAny = false;
    for (final message in conversation.messages) {
      if (message.readAt == null &&
          message.messageDirection == MessageDirection.incoming) {
        message.readAt = now;
        updatedAny = true;
      }
    }

    if (updatedAny) {
      conversationBox.put(conversation);
    }
  }
}
