import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late MockMessageRepository mockRepository;
  late ConversationBloc conversationBloc;
  late ConversationEntity tConversation;
  late MessageEntity tMessage;
  late List<ContactEntity> tContacts;

  setUpAll(() {
    registerFallbackValue(MessageDirection.incoming);
  });

  setUp(() {
    mockRepository = MockMessageRepository();
    conversationBloc = ConversationBloc(repository: mockRepository);
    tConversation = ConversationEntity(phoneNumber: '+1234567890')..id = 1;
    tMessage = MessageEntity(
      sender: '+1234567890',
      recipient: 'me',
      body: 'Hello',
      direction: MessageDirection.incoming.index,
      status: MessageStatus.delivered.index,
    )..id = 100;
    tContacts = [
      ContactEntity(name: 'Alice')..id = 1,
      ContactEntity(name: 'Bob')..id = 2,
    ];
  });

  tearDown(() {
    conversationBloc.close();
  });

  test('initial state should be ConversationInitial', () {
    expect(conversationBloc.state, const ConversationInitial());
  });

  group('LoadConversation', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [ConversationLoading, ConversationLoaded] when successful',
      build: () {
        when(
          () => mockRepository.markAllAsRead(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getConversationById(any()),
        ).thenAnswer((_) async => tConversation);
        when(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tMessage]);
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadConversation(1)),
      expect: () => [
        const ConversationLoading(),
        ConversationLoaded(
          conversation: tConversation,
          messages: [tMessage],
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.markAllAsRead(1)).called(1);
        verify(() => mockRepository.getConversationById(1)).called(1);
        verify(
          () => mockRepository.getMessagesForConversation(
            1,
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [ConversationLoading, ConversationError] when getConversationById returns null',
      build: () {
        when(
          () => mockRepository.markAllAsRead(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getConversationById(any()),
        ).thenAnswer((_) async => null);
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadConversation(1)),
      expect: () => [
        const ConversationLoading(),
        const ConversationError(ConversationErrorType.notFound),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [ConversationLoading, ConversationError] when repository throws error',
      build: () {
        when(
          () => mockRepository.markAllAsRead(any()),
        ).thenThrow(Exception('Mark read failure'));
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadConversation(1)),
      expect: () => [
        const ConversationLoading(),
        const ConversationError(ConversationErrorType.loadFailed),
      ],
    );
  });

  group('LoadMoreMessages', () {
    final tMessagesPageSize = List.generate(
      Constants.pageSize,
      (index) => MessageEntity(
        sender: '+1234567890',
        recipient: 'me',
        body: 'Message $index',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
      )..id = index,
    );
    final tMoreMessages = [
      MessageEntity(
        sender: '+1234567890',
        recipient: 'me',
        body: 'Older message',
        direction: MessageDirection.incoming.index,
        status: MessageStatus.delivered.index,
      )..id = 200,
    ];

    blocTest<ConversationBloc, ConversationState>(
      'emits [isLoadingMore: true, isLoadingMore: false] with more messages appended',
      build: () {
        when(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tMoreMessages);
        return conversationBloc;
      },
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: tMessagesPageSize,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreMessages()),
      expect: () => [
        ConversationLoaded(
          conversation: tConversation,
          messages: tMessagesPageSize,
          hasMore: true,
          isLoadingMore: true,
        ),
        ConversationLoaded(
          conversation: tConversation,
          messages: [...tMessagesPageSize, ...tMoreMessages],
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getMessagesForConversation(
            tConversation.id,
            limit: Constants.pageSize,
            offset: Constants.pageSize,
          ),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if current state is not ConversationLoaded',
      build: () => conversationBloc,
      act: (bloc) => bloc.add(const LoadMoreMessages()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if hasMore is false',
      build: () => conversationBloc,
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreMessages()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if isLoadingMore is true',
      build: () => conversationBloc,
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreMessages()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [isLoadingMore: true, isLoadingMore: false] and keeps original list when repository throws error',
      build: () {
        when(
          () => mockRepository.getMessagesForConversation(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Load more messages failure'));
        return conversationBloc;
      },
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreMessages()),
      expect: () => [
        ConversationLoaded(
          conversation: tConversation,
          messages: [tMessage],
          hasMore: true,
          isLoadingMore: true,
        ),
        ConversationLoaded(
          conversation: tConversation,
          messages: [tMessage],
          hasMore: true,
          isLoadingMore: false,
        ),
      ],
    );
  });

  group('SendMessage', () {
    final tNewMessage = MessageEntity(
      sender: 'me',
      recipient: '+1234567890',
      body: 'Outgoing message',
      direction: MessageDirection.outgoing.index,
      status: MessageStatus.sent.index,
    )..id = 300;

    blocTest<ConversationBloc, ConversationState>(
      'inserts message and prepends it to state messages list',
      build: () {
        when(
          () => mockRepository.insertMessage(any(), any(), any()),
        ).thenAnswer((_) async => tNewMessage);
        return conversationBloc;
      },
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const SendMessage('Outgoing message')),
      expect: () => [
        ConversationLoaded(
          conversation: tConversation,
          messages: [tNewMessage, tMessage],
          hasMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.insertMessage(
            tConversation.phoneNumber,
            'Outgoing message',
            MessageDirection.outgoing,
          ),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does nothing when sending empty message',
      build: () => conversationBloc,
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const SendMessage('   ')),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.insertMessage(any(), any(), any()),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does nothing when state is not ConversationLoaded',
      build: () => conversationBloc,
      act: (bloc) => bloc.add(const SendMessage('Hello')),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.insertMessage(any(), any(), any()),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [ConversationError] when repository fails to insert message',
      build: () {
        when(
          () => mockRepository.insertMessage(any(), any(), any()),
        ).thenThrow(Exception('Insert failure'));
        return conversationBloc;
      },
      seed: () => ConversationLoaded(
        conversation: tConversation,
        messages: [tMessage],
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const SendMessage('Outgoing message')),
      expect: () => [
        const ConversationError(ConversationErrorType.sendFailed),
      ],
    );
  });

  group('LoadComposeContacts', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [ComposeContactsLoading, ComposeContactsLoaded] on success',
      build: () {
        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tContacts);
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadComposeContacts()),
      expect: () => [
        const ComposeContactsLoading(),
        ComposeContactsLoaded(
          contacts: tContacts,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getContacts(
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits [ComposeContactsLoading, ComposeContactsError] on failure',
      build: () {
        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Database error'));
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadComposeContacts()),
      expect: () => [
        const ComposeContactsLoading(),
        const ComposeContactsError(ConversationErrorType.loadFailed),
      ],
    );
  });

  group('LoadComposeContacts with query', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [ComposeContactsLoading, ComposeContactsLoaded] with query search results',
      build: () {
        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tContacts[0]]);
        return conversationBloc;
      },
      act: (bloc) => bloc.add(const LoadComposeContacts(query: 'Ali')),
      expect: () => [
        const ComposeContactsLoading(),
        ComposeContactsLoaded(
          contacts: [tContacts[0]],
          searchQuery: 'Ali',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getContacts(
            query: 'Ali',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );
  });

  group('LoadMoreComposeContacts', () {
    final tContactsPage1 = List.generate(
      Constants.pageSize,
      (i) => ContactEntity(name: 'Contact $i')..id = i + 1,
    );
    final tContactsPage2 = [
      ContactEntity(name: 'Contact Last')..id = 999,
    ];

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if state is not ComposeContactsLoaded',
      build: () => conversationBloc,
      act: (bloc) => bloc.add(const LoadMoreComposeContacts()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if hasMore is false',
      build: () {
        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tContacts);
        return conversationBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadComposeContacts());
        await bloc.stream.firstWhere((s) => s is ComposeContactsLoaded);
        bloc.add(const LoadMoreComposeContacts());
      },
      expect: () => [
        const ComposeContactsLoading(),
        ComposeContactsLoaded(
          contacts: tContacts,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getContacts(
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
        verifyNever(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: 2,
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'does not fetch more if isLoadingMore is true',
      build: () => conversationBloc,
      seed: () => ComposeContactsLoaded(
        contacts: tContacts,
        searchQuery: '',
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreComposeContacts()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'fetches and appends next page of contacts when hasMore is true',
      build: () {
        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: 0,
          ),
        ).thenAnswer((_) async => tContactsPage1);

        when(
          () => mockRepository.getContacts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: Constants.pageSize,
          ),
        ).thenAnswer((_) async => tContactsPage2);

        return conversationBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadComposeContacts());
        await bloc.stream.firstWhere((s) => s is ComposeContactsLoaded);
        bloc.add(const LoadMoreComposeContacts());
      },
      expect: () => [
        const ComposeContactsLoading(),
        ComposeContactsLoaded(
          contacts: tContactsPage1,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: false,
        ),
        ComposeContactsLoaded(
          contacts: tContactsPage1,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: true,
        ),
        ComposeContactsLoaded(
          contacts: [...tContactsPage1, ...tContactsPage2],
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getContacts(
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
        verify(
          () => mockRepository.getContacts(
            query: '',
            limit: Constants.pageSize,
            offset: Constants.pageSize,
          ),
        ).called(1);
      },
    );
  });
}
