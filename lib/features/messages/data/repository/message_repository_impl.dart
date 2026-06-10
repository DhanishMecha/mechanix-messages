import 'package:mechanix_messages/core/services/objectbox_service.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/core/utils/app_logger.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_entity.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/objectbox.g.dart';

class MessageRepositoryImpl implements MessageRepository {
  ObjectBoxService? _objectBox;

  MessageRepositoryImpl({ObjectBoxService? objectBox}) : _objectBox = objectBox;

  Future<ObjectBoxService> _getBox() async {
    try {
      if (_objectBox == null) {
        AppLogger.i('Initializing ObjectBox  connections...');
        await ContactsStoreService.ensureConnected();
        _objectBox = await ObjectBoxService.init();
        AppLogger.i('ObjectBox initialized successfully.');
      }
      return _objectBox!;
    } catch (e, stack) {
      AppLogger.e('Failed to initialize ObjectBox', error: e, stack: stack);
      rethrow;
    }
  }

  ContactEntity? _getContactForPhoneNumber(String phoneNumber) {
    try {
      final phoneBox = ContactsStoreService.phoneNumbers;
      final query = phoneBox
          .query(PhoneNumberEntity_.number.equals(phoneNumber))
          .build();
      final phoneEntity = query.findFirst();
      query.close();
      return phoneEntity?.contact.target;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ConversationEntity>> getConversations({
    ConversationFilter filter = ConversationFilter.all,
    String query = '',
    int limit = Constants.pageSize,
    int offset = 0,
  }) async {
    try {
      final boxService = await _getBox();
      final conversationBox = boxService.store.box<ConversationEntity>();

      Condition<ConversationEntity>? cond;

      // 1. Filter by unread status if required
      if (filter == ConversationFilter.unread) {
        final messageBox = boxService.store.box<MessageEntity>();
        final unreadQuery = messageBox
            .query(
              MessageEntity_.readAt.isNull().and(
                MessageEntity_.direction.equals(
                  MessageDirection.incoming.index,
                ),
              ),
            )
            .build();
        final unreadMessages = unreadQuery.find();
        unreadQuery.close();

        if (unreadMessages.isEmpty) {
          AppLogger.d(
            'Loaded 0 unread conversations from database (short circuit).',
          );
          return <ConversationEntity>[];
        }

        final unreadConvIds = unreadMessages
            .map((m) => m.conversation.targetId)
            .toSet()
            .toList();
        cond = ConversationEntity_.id.oneOf(unreadConvIds);
      }

      // 2. Filter by search query if present
      if (query.isNotEmpty) {
        final List<String> matchingContactPhoneNumbers = [];
        try {
          final contactBox = ContactsStoreService.contacts;
          final cQuery = contactBox
              .query(ContactEntity_.name.contains(query, caseSensitive: false))
              .build();
          final matchingContacts = cQuery.find();
          cQuery.close();
          for (final contact in matchingContacts) {
            for (final phone in contact.phoneNumbers) {
              matchingContactPhoneNumbers.add(phone.number);
            }
          }
        } catch (_) {}

        final messageBox = boxService.store.box<MessageEntity>();
        final mQuery = messageBox
            .query(MessageEntity_.body.contains(query, caseSensitive: false))
            .build();
        final matchingMessages = mQuery.find();
        mQuery.close();
        final convIdsFromMessages = matchingMessages
            .map((m) => m.conversation.targetId)
            .toSet()
            .toList();

        Condition<ConversationEntity> searchCond = ConversationEntity_
            .phoneNumber
            .contains(query, caseSensitive: false);

        if (matchingContactPhoneNumbers.isNotEmpty) {
          searchCond = searchCond.or(
            ConversationEntity_.phoneNumber.oneOf(matchingContactPhoneNumbers),
          );
        }

        if (convIdsFromMessages.isNotEmpty) {
          searchCond = searchCond.or(
            ConversationEntity_.id.oneOf(convIdsFromMessages),
          );
        }

        if (cond == null) {
          cond = searchCond;
        } else {
          cond = cond.and(searchCond);
        }
      }

      final queryBuilder = conversationBox.query(cond)
        ..order(ConversationEntity_.updatedAt, flags: Order.descending);
      final q = queryBuilder.build()
        ..limit = limit
        ..offset = offset;
      final conversations = q.find();
      q.close();

      final phoneNumbers = conversations.map((c) => c.phoneNumber).toList();
      if (phoneNumbers.isNotEmpty) {
        final phoneBox = ContactsStoreService.phoneNumbers;
        final phoneQuery = phoneBox
            .query(PhoneNumberEntity_.number.oneOf(phoneNumbers))
            .build();
        final phoneEntities = phoneQuery.find();
        phoneQuery.close();

        final contactMap = <String, ContactEntity>{};
        for (final pe in phoneEntities) {
          final contact = pe.contact.target;
          if (contact != null) {
            contactMap[pe.number] = contact;
          }
        }

        for (final conv in conversations) {
          conv.contact = contactMap[conv.phoneNumber];
        }
      }

      final messageBox = boxService.store.box<MessageEntity>();
      for (final conv in conversations) {
        _populateLastMessageAndUnread(conv, messageBox);
      }

      AppLogger.d(
        'Loaded ${conversations.length} conversations from database (filter: $filter, query: "$query").',
      );
      return conversations;
    } catch (e, stack) {
      AppLogger.e(
        'Error loading conversations from database',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  void _populateLastMessageAndUnread(
    ConversationEntity conversation,
    Box<MessageEntity> messageBox,
  ) {
    if (conversation.id == 0) return;

    final lastMsgQuery = messageBox.query(
      MessageEntity_.conversation.equals(conversation.id),
    )..order(MessageEntity_.createdAt, flags: Order.descending);
    final lastMsgBuild = lastMsgQuery.build()..limit = 1;
    final lastMsgList = lastMsgBuild.find();
    lastMsgBuild.close();
    if (lastMsgList.isNotEmpty) {
      conversation.lastMessage = lastMsgList.first;
    }

    final unreadQuery = messageBox
        .query(
          MessageEntity_.conversation
              .equals(conversation.id)
              .and(
                MessageEntity_.readAt.isNull().and(
                  MessageEntity_.direction.equals(
                    MessageDirection.incoming.index,
                  ),
                ),
              ),
        )
        .build();
    conversation.hasUnread = unreadQuery.count() > 0;
    unreadQuery.close();
  }

  @override
  Future<ConversationEntity?> getConversationById(int id) async {
    try {
      final boxService = await _getBox();
      final conversation = boxService.store.box<ConversationEntity>().get(id);
      if (conversation != null) {
        conversation.contact = _getContactForPhoneNumber(
          conversation.phoneNumber,
        );
        _populateLastMessageAndUnread(
          conversation,
          boxService.store.box<MessageEntity>(),
        );
        AppLogger.d('Loaded conversation by ID: $id');
      } else {
        AppLogger.d('Conversation with ID: $id not found.');
      }
      return conversation;
    } catch (e, stack) {
      AppLogger.e(
        'Error loading conversation by ID: $id',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<ConversationEntity> getOrCreateConversation(String phoneNumber) async {
    try {
      final boxService = await _getBox();
      final conversationBox = boxService.store.box<ConversationEntity>();

      final query = conversationBox
          .query(ConversationEntity_.phoneNumber.equals(phoneNumber))
          .build();
      ConversationEntity? conversation = query.findFirst();
      query.close();

      if (conversation == null) {
        AppLogger.i(
          'Creating new ConversationEntity for phoneNumber: $phoneNumber',
        );
        final now = DateTime.now();
        conversation = ConversationEntity(
          phoneNumber: phoneNumber,
          createdAt: now,
          updatedAt: now,
        );

        conversationBox.put(conversation);
        AppLogger.i('New ConversationEntity saved for: $phoneNumber');
      } else {
        AppLogger.d('Found existing ConversationEntity for: $phoneNumber');
      }

      conversation.contact = _getContactForPhoneNumber(phoneNumber);
      _populateLastMessageAndUnread(
        conversation,
        boxService.store.box<MessageEntity>(),
      );
      return conversation;
    } catch (e, stack) {
      AppLogger.e(
        'Error in getOrCreateConversation for: $phoneNumber',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<MessageEntity> insertMessage(
    String phoneNumber,
    String body,
    MessageDirection direction,
  ) async {
    try {
      final boxService = await _getBox();
      final conversationBox = boxService.store.box<ConversationEntity>();
      final messageBox = boxService.store.box<MessageEntity>();

      final query = conversationBox
          .query(ConversationEntity_.phoneNumber.equals(phoneNumber))
          .build();
      ConversationEntity? conversation = query.findFirst();
      query.close();

      final now = DateTime.now();

      if (conversation == null) {
        AppLogger.i(
          'Implicitly creating new ConversationEntity inside insertMessage for: $phoneNumber',
        );
        conversation = ConversationEntity(
          phoneNumber: phoneNumber,
          createdAt: now,
          updatedAt: now,
        );
      } else {
        conversation.updatedAt = now;
      }

      conversation.contact = _getContactForPhoneNumber(phoneNumber);

      final message = MessageEntity(
        sender: direction == MessageDirection.incoming ? phoneNumber : 'me',
        recipient: direction == MessageDirection.outgoing ? phoneNumber : 'me',
        body: body,
        direction: direction.index,
        status: MessageStatus.sent.index,
        createdAt: now,
      );

      message.conversation.target = conversation;

      boxService.store.runInTransaction(TxMode.write, () {
        conversationBox.put(conversation!);
        messageBox.put(message);
      });

      AppLogger.i('Successfully inserted message for: $phoneNumber');

      return message;
    } catch (e, stack) {
      AppLogger.e(
        'Error inserting message for: $phoneNumber',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(int conversationId) async {
    try {
      final boxService = await _getBox();
      final messageBox = boxService.store.box<MessageEntity>();

      final builder = messageBox.query(
        MessageEntity_.readAt.isNull() &
            MessageEntity_.direction.equals(MessageDirection.incoming.index),
      );

      builder.link(
        MessageEntity_.conversation,
        ConversationEntity_.id.equals(conversationId),
      );

      final query = builder.build();
      final unreadMessages = query.find();
      query.close();

      if (unreadMessages.isEmpty) return;

      final now = DateTime.now();
      for (final message in unreadMessages) {
        message.readAt = now;
      }

      messageBox.putMany(unreadMessages);

      AppLogger.i(
        'Marked ${unreadMessages.length} messages as read '
        'for conversation ID: $conversationId',
      );
    } catch (e, stack) {
      AppLogger.e(
        'Error marking all messages as read for ID: $conversationId',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  @override
  Future<List<MessageEntity>> getMessagesForConversation(
    int conversationId, {
    int limit = Constants.pageSize,
    int offset = 0,
  }) async {
    try {
      final boxService = await _getBox();
      final messageBox = boxService.store.box<MessageEntity>();

      final builder = messageBox.query(
        MessageEntity_.conversation.equals(conversationId),
      )..order(MessageEntity_.createdAt, flags: Order.descending);

      final query = builder.build()
        ..limit = limit
        ..offset = offset;

      final messages = query.find();
      query.close();

      AppLogger.d(
        'Loaded ${messages.length} messages for conversation $conversationId (limit: $limit, offset: $offset)',
      );
      return messages;
    } catch (e, stack) {
      AppLogger.e(
        'Error loading messages for conversation $conversationId',
        error: e,
        stack: stack,
      );
      return [];
    }
  }

  @override
  Future<List<ContactEntity>> getContacts({
    String query = '',
    int limit = Constants.pageSize,
    int offset = 0,
  }) async {
    try {
      await _getBox();
      final contactBox = ContactsStoreService.contacts;

      Condition<ContactEntity>? cond;
      if (query.isNotEmpty) {
        // @Backlink relations don't support .link() in a condition chain.
        // QueryBuilder.linkMany() exists but is AND-only, so we still need
        // a phone pre-query to build the OR condition.
        final phoneBox = ContactsStoreService.phoneNumbers;
        final phoneQ = phoneBox
            .query(
              PhoneNumberEntity_.number.contains(query, caseSensitive: false),
            )
            .build();
        final matchingContactIds = phoneQ
            .find()
            .map((p) => p.contact.targetId)
            .where((id) => id != 0)
            .toSet() // deduplicate — multiple phones on same contact
            .toList();
        phoneQ.close();

        cond = ContactEntity_.name.contains(query, caseSensitive: false);
        if (matchingContactIds.isNotEmpty) {
          cond = cond.or(ContactEntity_.id.oneOf(matchingContactIds));
        }
      }

      // Single contact query with DB-level ordering
      final q = (contactBox.query(cond)..order(ContactEntity_.name)).build();
      final contacts = q.find();
      q.close();

      final expanded = <ContactEntity>[];
      for (final contact in contacts) {
        if (contact.phoneNumbers.isEmpty) {
          expanded.add(contact);
        } else {
          for (final phone in contact.phoneNumbers) {
            expanded.add(
              ContactEntity(name: contact.name, favorite: contact.favorite)
                ..id = contact.id
                ..phoneNumbers.add(phone)
                ..emails.addAll(contact.emails),
            );
          }
        }
      }

      if (offset >= expanded.length) return [];
      final end = (offset + limit).clamp(0, expanded.length);

      AppLogger.d(
        'Loaded ${end - offset} contacts (limit: $limit, offset: $offset, query: "$query")',
      );
      return expanded.sublist(offset, end);
    } catch (e, stack) {
      AppLogger.e(
        'Error loading contacts from database',
        error: e,
        stack: stack,
      );
      return [];
    }
  }
}
