import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mechanix_messages/core/services/objectbox_service.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_entity.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/objectbox.g.dart' as messages_g;
import 'package:mechanix_contacts/objectbox.g.dart' as contacts_g;

class MockStore extends Mock implements Store {}
class MockObjectBoxService extends Mock implements ObjectBoxService {}

int _testDbCounter = 0;

void main() {
  late Store messagesStore;
  late Store contactsStore;
  late MessageRepositoryImpl repository;

  setUp(() {
    _testDbCounter++;
    // 1. Create in-memory stores for testing with unique directories
    messagesStore = Store(
      messages_g.getObjectBoxModel(),
      directory: 'memory:messages-db-$_testDbCounter',
    );
    contactsStore = Store(
      contacts_g.getObjectBoxModel(),
      directory: 'memory:contacts-db-$_testDbCounter',
    );

    // 2. Inject stores into Services
    final mockObjectBox = MockObjectBoxService();
    when(() => mockObjectBox.store).thenReturn(messagesStore);
    ContactsStoreService.storeForTesting = contactsStore;

    // 3. Initialize repository using constructor injection
    repository = MessageRepositoryImpl(objectBox: mockObjectBox);
  });

  tearDown(() {
    // Close stores and clear mock settings
    messagesStore.close();
    contactsStore.close();
    ContactsStoreService.storeForTesting = null;
  });

  group('getConversations', () {
    test('returns conversations ordered by updatedAt descending', () async {
      final box = messagesStore.box<ConversationEntity>();
      final now = DateTime.now();

      final conv1 = ConversationEntity(
        phoneNumber: '+1111111111',
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      );
      final conv2 = ConversationEntity(
        phoneNumber: '+2222222222',
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now,
      );

      box.putMany([conv1, conv2]);

      final conversations = await repository.getConversations();

      expect(conversations.length, 2);
      expect(conversations.first.phoneNumber, '+2222222222');
      expect(conversations.last.phoneNumber, '+1111111111');
    });

    test('respects limit and offset paging parameters', () async {
      final box = messagesStore.box<ConversationEntity>();
      final now = DateTime.now();

      final conversations = List.generate(
        5,
        (i) => ConversationEntity(
          phoneNumber: '+$i',
          createdAt: now,
          updatedAt: now.subtract(Duration(minutes: i)),
        ),
      );

      box.putMany(conversations);

      final page = await repository.getConversations(limit: 2, offset: 1);

      expect(page.length, 2);
      expect(page[0].phoneNumber, '+1');
      expect(page[1].phoneNumber, '+2');
    });

    test('populates contact details if contact exists in ContactsStore', () async {
      // 1. Add contact to ContactsStore
      final contactBox = contactsStore.box<ContactEntity>();
      final phoneBox = contactsStore.box<PhoneNumberEntity>();

      final contact = ContactEntity(name: 'John Doe');
      contactBox.put(contact);

      final phone = PhoneNumberEntity(number: '+1234567890');
      phone.contact.target = contact;
      phoneBox.put(phone);

      // 2. Add conversation
      final conversationBox = messagesStore.box<ConversationEntity>();
      final conv = ConversationEntity(
        phoneNumber: '+1234567890',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      conversationBox.put(conv);

      final conversations = await repository.getConversations();

      expect(conversations.first.contact, isNotNull);
      expect(conversations.first.contact!.name, 'John Doe');
    });

    test('filters unread conversations correctly and populates hasUnread/lastMessage', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv1 = ConversationEntity(phoneNumber: '+1', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final conv2 = ConversationEntity(phoneNumber: '+2', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.putMany([conv1, conv2]);

      // conv1 has an unread incoming message
      final msg1 = MessageEntity(
        sender: '+1',
        recipient: 'me',
        body: 'unread msg',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg1.conversation.target = conv1;

      // conv2 has a read incoming message
      final msg2 = MessageEntity(
        sender: '+2',
        recipient: 'me',
        body: 'read msg',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
        readAt: DateTime.now(),
      );
      msg2.conversation.target = conv2;

      messageBox.putMany([msg1, msg2]);

      // 1. Check filtering for unread
      final unreadConversations = await repository.getConversations(
        filter: ConversationFilter.unread,
      );

      expect(unreadConversations.length, 1);
      expect(unreadConversations.first.phoneNumber, '+1');
      expect(unreadConversations.first.hasUnread, isTrue);
      expect(unreadConversations.first.lastMessage, isNotNull);
      expect(unreadConversations.first.lastMessage!.body, 'unread msg');

      // 2. Check getConversations overall hasUnread/lastMessage population
      final allConversations = await repository.getConversations(
        filter: ConversationFilter.all,
      );
      final listConv1 = allConversations.firstWhere((c) => c.phoneNumber == '+1');
      final listConv2 = allConversations.firstWhere((c) => c.phoneNumber == '+2');

      expect(listConv1.hasUnread, isTrue);
      expect(listConv1.lastMessage!.body, 'unread msg');

      expect(listConv2.hasUnread, isFalse);
      expect(listConv2.lastMessage!.body, 'read msg');
    });

    test('returns empty list immediately if unread filter requested and there are no unread incoming messages', () async {
      final results = await repository.getConversations(filter: ConversationFilter.unread);
      expect(results, isEmpty);
    });

    test('filters unread conversations combined with search query', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv1 = ConversationEntity(phoneNumber: '+111', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final conv2 = ConversationEntity(phoneNumber: '+222', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.putMany([conv1, conv2]);

      // conv1: unread, matches search query "hello"
      final msg1 = MessageEntity(
        sender: '+111',
        recipient: 'me',
        body: 'hello world',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg1.conversation.target = conv1;

      // conv2: unread, does NOT match query "hello"
      final msg2 = MessageEntity(
        sender: '+222',
        recipient: 'me',
        body: 'goodbye',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg2.conversation.target = conv2;

      messageBox.putMany([msg1, msg2]);

      final results = await repository.getConversations(
        filter: ConversationFilter.unread,
        query: 'hello',
      );

      expect(results.length, 1);
      expect(results.first.phoneNumber, '+111');
    });

    test('searches by conversation phone number', () async {
      final box = messagesStore.box<ConversationEntity>();
      box.putMany([
        ConversationEntity(phoneNumber: '+12345', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        ConversationEntity(phoneNumber: '+99999', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ]);

      final results = await repository.getConversations(query: '234');

      expect(results.length, 1);
      expect(results.first.phoneNumber, '+12345');
    });

    test('searches by message body', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv1 = ConversationEntity(phoneNumber: '+1', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final conv2 = ConversationEntity(phoneNumber: '+2', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.putMany([conv1, conv2]);

      final msg1 = MessageEntity(
        sender: '+1',
        recipient: 'me',
        body: 'Matching search key',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg1.conversation.target = conv1;

      final msg2 = MessageEntity(
        sender: '+2',
        recipient: 'me',
        body: 'Hello world',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg2.conversation.target = conv2;

      messageBox.putMany([msg1, msg2]);

      final results = await repository.getConversations(query: 'search');

      expect(results.length, 1);
      expect(results.first.phoneNumber, '+1');
    });

    test('searches by contact name in ContactsStore', () async {
      // 1. Add contact to ContactsStore matching query
      final contactBox = contactsStore.box<ContactEntity>();
      final phoneBox = contactsStore.box<PhoneNumberEntity>();

      final contact = ContactEntity(name: 'Alice Cooper');
      contactBox.put(contact);

      final phone = PhoneNumberEntity(number: '+55555');
      phone.contact.target = contact;
      phoneBox.put(phone);

      // 2. Add conversation matching that phone number
      final conversationBox = messagesStore.box<ConversationEntity>();
      final conv = ConversationEntity(
        phoneNumber: '+55555',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      conversationBox.put(conv);

      final results = await repository.getConversations(query: 'Alice');

      expect(results.length, 1);
      expect(results.first.phoneNumber, '+55555');
    });

    test('rethrows exception when getConversations database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<ConversationEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      expect(
        () => repository.getConversations(),
        throwsA(anything),
      );
    });
  });

  group('getConversationById', () {
    test('returns correct conversation, populates last message, hasUnread, and contact', () async {
      // 1. Add contact to ContactsStore
      final contactBox = contactsStore.box<ContactEntity>();
      final phoneBox = contactsStore.box<PhoneNumberEntity>();

      final contact = ContactEntity(name: 'Jane Smith');
      contactBox.put(contact);

      final phone = PhoneNumberEntity(number: '+1234567890');
      phone.contact.target = contact;
      phoneBox.put(phone);

      // 2. Add conversation & unread message
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv = ConversationEntity(
        phoneNumber: '+1234567890',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      conversationBox.put(conv);

      final msg1 = MessageEntity(
        sender: '+1234567890',
        recipient: 'me',
        body: 'First',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      msg1.conversation.target = conv;

      final msg2 = MessageEntity(
        sender: '+1234567890',
        recipient: 'me',
        body: 'Second (latest)',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg2.conversation.target = conv;

      messageBox.putMany([msg1, msg2]);

      final result = await repository.getConversationById(conv.id);

      expect(result, isNotNull);
      expect(result!.phoneNumber, '+1234567890');
      
      // Verify relations populated
      expect(result.contact, isNotNull);
      expect(result.contact!.name, 'Jane Smith');
      expect(result.lastMessage, isNotNull);
      expect(result.lastMessage!.body, 'Second (latest)');
      expect(result.hasUnread, isTrue);
    });

    test('returns null if conversation id not found', () async {
      final result = await repository.getConversationById(999);
      expect(result, isNull);
    });

    test('rethrows exception when getConversationById database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<ConversationEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      expect(
        () => repository.getConversationById(1),
        throwsA(anything),
      );
    });
  });

  group('getOrCreateConversation', () {
    test('returns existing conversation with populated contact and lastMessage if match found', () async {
      // 1. Add contact to ContactsStore
      final contactBox = contactsStore.box<ContactEntity>();
      final phoneBox = contactsStore.box<PhoneNumberEntity>();

      final contact = ContactEntity(name: 'Jane Smith');
      contactBox.put(contact);

      final phone = PhoneNumberEntity(number: '+123');
      phone.contact.target = contact;
      phoneBox.put(phone);

      // 2. Add conversation and message
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv = ConversationEntity(
        phoneNumber: '+123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      conversationBox.put(conv);

      final msg = MessageEntity(
        sender: '+123',
        recipient: 'me',
        body: 'Last msg text',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg.conversation.target = conv;
      messageBox.put(msg);

      final result = await repository.getOrCreateConversation('+123');

      expect(result.id, conv.id);
      expect(conversationBox.count(), 1);
      
      // Verify population
      expect(result.contact, isNotNull);
      expect(result.contact!.name, 'Jane Smith');
      expect(result.lastMessage, isNotNull);
      expect(result.lastMessage!.body, 'Last msg text');
    });

    test('creates new conversation if no match found', () async {
      final box = messagesStore.box<ConversationEntity>();
      expect(box.count(), 0);

      final result = await repository.getOrCreateConversation('+123');

      expect(result.id, isNot(0));
      expect(result.phoneNumber, '+123');
      expect(box.count(), 1);
    });

    test('rethrows exception when getOrCreateConversation database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<ConversationEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      expect(
        () => repository.getOrCreateConversation('+123'),
        throwsA(anything),
      );
    });
  });

  group('insertMessage', () {
    test('inserts message and updates conversation updatedAt', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final now = DateTime.now();
      final conv = ConversationEntity(
        phoneNumber: '+123',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      );
      conversationBox.put(conv);

      final msg = await repository.insertMessage('+123', 'New msg', MessageDirection.outgoing);

      expect(msg.id, isNot(0));
      expect(msg.body, 'New msg');
      expect(msg.sender, 'me');
      expect(msg.recipient, '+123');
      expect(messageBox.count(), 1);

      // Verify conversation updated
      final updatedConv = conversationBox.get(conv.id)!;
      expect(updatedConv.updatedAt.isAfter(now), true);
    });

    test('inserts incoming message correctly (sets sender to phone number, recipient to me)', () async {
      final msg = await repository.insertMessage('+123', 'Incoming msg', MessageDirection.incoming);
      expect(msg.sender, '+123');
      expect(msg.recipient, 'me');
      expect(msg.body, 'Incoming msg');
    });

    test('implicitly creates a new conversation if it does not exist during insertMessage', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      expect(conversationBox.count(), 0);

      final msg = await repository.insertMessage('+987', 'Implicit creation', MessageDirection.outgoing);

      expect(msg.conversation.target, isNotNull);
      expect(msg.conversation.target!.phoneNumber, '+987');
      expect(conversationBox.count(), 1);
    });

    test('rethrows exception when insertMessage database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<ConversationEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      expect(
        () => repository.insertMessage('+123', 'msg', MessageDirection.outgoing),
        throwsA(anything),
      );
    });
  });

  group('markAllAsRead', () {
    test('marks all incoming unread messages as read only for target conversation, leaving others untouched', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv1 = ConversationEntity(phoneNumber: '+123', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final conv2 = ConversationEntity(phoneNumber: '+456', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.putMany([conv1, conv2]);

      // conv1 unread incoming message
      final msg1 = MessageEntity(
        sender: '+123',
        recipient: 'me',
        body: 'msg1',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg1.conversation.target = conv1;

      // conv2 unread incoming message
      final msg2 = MessageEntity(
        sender: '+456',
        recipient: 'me',
        body: 'msg2',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg2.conversation.target = conv2;

      // conv1 already-read message (should remain untouched)
      final readAtPast = DateTime.now().subtract(const Duration(hours: 2));
      final msg3 = MessageEntity(
        sender: '+123',
        recipient: 'me',
        body: 'msg3',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        readAt: readAtPast,
      );
      msg3.conversation.target = conv1;

      messageBox.putMany([msg1, msg2, msg3]);

      await repository.markAllAsRead(conv1.id);

      final updatedMsg1 = messageBox.get(msg1.id)!;
      final updatedMsg2 = messageBox.get(msg2.id)!;
      final updatedMsg3 = messageBox.get(msg3.id)!;

      expect(updatedMsg1.readAt, isNotNull); // Marked read
      expect(updatedMsg2.readAt, isNull);    // Different conversation - untouched
      expect(updatedMsg3.readAt?.millisecondsSinceEpoch, readAtPast.millisecondsSinceEpoch); // Already read - unchanged
    });

    test('does nothing and returns early if there are no unread incoming messages', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();

      final conv = ConversationEntity(phoneNumber: '+123', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.put(conv);

      // Execute without incoming messages
      await repository.markAllAsRead(conv.id);
      // Verification that it executes without throwing and finishes successfully
    });

    test('rethrows exception when markAllAsRead database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<MessageEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      expect(
        () => repository.markAllAsRead(1),
        throwsA(anything),
      );
    });
  });

  group('getMessagesForConversation', () {
    test('returns messages in descending order of createdAt, filtered by target conversation', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv1 = ConversationEntity(phoneNumber: '+123', createdAt: DateTime.now(), updatedAt: DateTime.now());
      final conv2 = ConversationEntity(phoneNumber: '+456', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.putMany([conv1, conv2]);

      final msg1 = MessageEntity(
        sender: '+123',
        recipient: 'me',
        body: 'first',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      msg1.conversation.target = conv1;

      final msg2 = MessageEntity(
        sender: '+123',
        recipient: 'me',
        body: 'second',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msg2.conversation.target = conv1;

      // message in other conversation (should not be included)
      final msgOther = MessageEntity(
        sender: '+456',
        recipient: 'me',
        body: 'other conv msg',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
        createdAt: DateTime.now(),
      );
      msgOther.conversation.target = conv2;

      messageBox.putMany([msg1, msg2, msgOther]);

      final messages = await repository.getMessagesForConversation(conv1.id);

      expect(messages.length, 2);
      expect(messages.first.body, 'second');
      expect(messages.last.body, 'first');
    });

    test('respects limit and offset pagination parameters', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final messageBox = messagesStore.box<MessageEntity>();

      final conv = ConversationEntity(phoneNumber: '+123', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.put(conv);

      final now = DateTime.now();
      final messages = List.generate(
        5,
        (i) => MessageEntity(
          sender: '+123',
          recipient: 'me',
          body: 'Message $i',
          direction: MessageDirection.incoming.index,
          status: MessageStatus.delivered.index,
          createdAt: now.subtract(Duration(minutes: i)),
        )..conversation.target = conv,
      );

      messageBox.putMany(messages);

      final page = await repository.getMessagesForConversation(conv.id, limit: 2, offset: 1);

      expect(page.length, 2);
      expect(page[0].body, 'Message 1');
      expect(page[1].body, 'Message 2');
    });

    test('returns empty list for conversation with zero messages', () async {
      final conversationBox = messagesStore.box<ConversationEntity>();
      final conv = ConversationEntity(phoneNumber: '+123', createdAt: DateTime.now(), updatedAt: DateTime.now());
      conversationBox.put(conv);

      final messages = await repository.getMessagesForConversation(conv.id);
      expect(messages, isEmpty);
    });

    test('returns empty list [] when getMessagesForConversation database fails', () async {
      final mockStore = MockStore();
      when(() => mockStore.isClosed()).thenReturn(false);
      when(() => mockStore.box<MessageEntity>()).thenThrow(StateError('Closed'));
      
      final mockObjectBox = MockObjectBoxService();
      when(() => mockObjectBox.store).thenReturn(mockStore);
      repository = MessageRepositoryImpl(objectBox: mockObjectBox);

      final messages = await repository.getMessagesForConversation(1);
      expect(messages, isEmpty);
    });
  });

  group('getContacts', () {
    test('returns contacts sorted alphabetically by name', () async {
      final contactBox = contactsStore.box<ContactEntity>();
      final c1 = ContactEntity(name: 'Charlie');
      final c2 = ContactEntity(name: 'Alice');
      final c3 = ContactEntity(name: 'Bob');
      contactBox.putMany([c1, c2, c3]);

      final contacts = await repository.getContacts();

      expect(contacts.length, 3);
      expect(contacts[0].name, 'Alice');
      expect(contacts[1].name, 'Bob');
      expect(contacts[2].name, 'Charlie');
    });

    test('respects limit and offset paging parameters', () async {
      final contactBox = contactsStore.box<ContactEntity>();
      final contacts = List.generate(
        5,
        (i) => ContactEntity(name: 'Contact ${String.fromCharCode(65 + i)}'), // A, B, C, D, E
      );
      contactBox.putMany(contacts);

      final page = await repository.getContacts(limit: 2, offset: 1);

      expect(page.length, 2);
      expect(page[0].name, 'Contact B');
      expect(page[1].name, 'Contact C');
    });

    test('filters by query matching contact name case-insensitively', () async {
      final contactBox = contactsStore.box<ContactEntity>();
      final c1 = ContactEntity(name: 'John Doe');
      final c2 = ContactEntity(name: 'Jane Smith');
      final c3 = ContactEntity(name: 'Johnny Cooper');
      contactBox.putMany([c1, c2, c3]);

      final results = await repository.getContacts(query: 'john');

      expect(results.length, 2);
      expect(results[0].name, 'John Doe');
      expect(results[1].name, 'Johnny Cooper');
    });

    test('filters by query matching contact phone number case-insensitively', () async {
      final contactBox = contactsStore.box<ContactEntity>();
      final phoneBox = contactsStore.box<PhoneNumberEntity>();

      final c1 = ContactEntity(name: 'Alice');
      final c2 = ContactEntity(name: 'Bob');
      contactBox.putMany([c1, c2]);

      final p1 = PhoneNumberEntity(number: '+123456');
      p1.contact.target = c1;

      final p2 = PhoneNumberEntity(number: '+987654');
      p2.contact.target = c2;

      phoneBox.putMany([p1, p2]);

      final results = await repository.getContacts(query: '1234');

      expect(results.length, 1);
      expect(results.first.name, 'Alice');
    });

    test('returns empty list [] when database fails', () async {
      // Temporarily set the store to null/closed to trigger exception
      ContactsStoreService.storeForTesting = null;

      final results = await repository.getContacts();
      expect(results, isEmpty);
    });
  });
}
