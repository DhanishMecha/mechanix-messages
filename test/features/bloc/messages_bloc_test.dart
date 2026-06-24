import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';

class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late MockMessageRepository mockRepository;
  late MessagesBloc messagesBloc;
  late List<ConversationModel> tConversations;

  setUpAll(() {
    registerFallbackValue(ConversationFilter.all);
  });

  setUp(() {
    mockRepository = MockMessageRepository();
    messagesBloc = MessagesBloc(repository: mockRepository);
    final now = DateTime.now();
    tConversations = [
      ConversationModel(
        id: 1,
        phoneNumber: '+1234567890',
        createdAt: now,
        updatedAt: now,
      ),
      ConversationModel(
        id: 2,
        phoneNumber: '+0987654321',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  });

  tearDown(() {
    messagesBloc.close();
  });

  test('initial state should be MessagesInitial', () {
    expect(messagesBloc.state, const MessagesInitial());
  });

  group('LoadConversations', () {
    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesLoaded] with all conversations on success',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tConversations);
        return messagesBloc;
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.all,
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesError] on repository failure',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Database error'));
        return messagesBloc;
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        const MessagesLoading(),
        const MessagesError(MessagesErrorType.loadFailed),
      ],
    );
  });

  group('FilterConversations', () {
    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesLoaded] with unread filter and query',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tConversations);
        return messagesBloc;
      },
      act: (bloc) => bloc.add(
        const FilterConversations(ConversationFilter.unread, query: 'test'),
      ),
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.unread,
          searchQuery: 'test',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.unread,
            query: 'test',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesLoaded] using current searchQuery when event.query is null and current state is MessagesLoaded',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tConversations);
        return messagesBloc;
      },
      seed: () => MessagesLoaded(
        conversations: tConversations,
        filter: ConversationFilter.all,
        searchQuery: 'previous_query',
        hasMore: false,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(
        const FilterConversations(ConversationFilter.unread, query: null),
      ),
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.unread,
          searchQuery: 'previous_query',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.unread,
            query: 'previous_query',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesLoaded] using empty query when event.query is null and current state is not MessagesLoaded',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tConversations);
        return messagesBloc;
      },
      act: (bloc) => bloc.add(
        const FilterConversations(ConversationFilter.unread, query: null),
      ),
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.unread,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.unread,
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'emits [MessagesLoading, MessagesError] when repository throws error',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Filter failure'));
        return messagesBloc;
      },
      act: (bloc) => bloc.add(
        const FilterConversations(ConversationFilter.unread, query: 'test'),
      ),
      expect: () => [
        const MessagesLoading(),
        const MessagesError(MessagesErrorType.loadFailed),
      ],
    );
  });

  group('LoadMoreConversations', () {
    final tTime = DateTime(2026, 6, 11);
    final tConversationsPage1 = List.generate(
      Constants.pageSize,
      (i) => ConversationModel(
        id: i + 1,
        phoneNumber: '+$i',
        createdAt: tTime,
        updatedAt: tTime,
      ),
    );
    final tConversationsPage2 = [
      ConversationModel(
        id: 999,
        phoneNumber: '+999',
        createdAt: tTime,
        updatedAt: tTime,
      ),
    ];

    blocTest<MessagesBloc, MessagesState>(
      'does not fetch more if current state is not MessagesLoaded',
      build: () => messagesBloc,
      act: (bloc) => bloc.add(const LoadMoreConversations()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'does not fetch more if hasMore is false',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => tConversations);
        return messagesBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadConversations());
        await bloc.stream.firstWhere((s) => s is MessagesLoaded);
        bloc.add(const LoadMoreConversations());
      },
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.all,
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
        verifyNever(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: 2,
          ),
        );
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'does not fetch more if isLoadingMore is true',
      build: () => messagesBloc,
      seed: () => MessagesLoaded(
        conversations: tConversations,
        filter: ConversationFilter.all,
        searchQuery: '',
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(const LoadMoreConversations()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'fetches and appends next page of conversations when hasMore is true',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: 0,
          ),
        ).thenAnswer((_) async => tConversationsPage1);

        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: Constants.pageSize,
          ),
        ).thenAnswer((_) async => tConversationsPage2);

        return messagesBloc;
      },
      act: (bloc) async {
        bloc.add(const LoadConversations());
        await bloc.stream.firstWhere((s) => s is MessagesLoaded);
        bloc.add(const LoadMoreConversations());
      },
      expect: () => [
        const MessagesLoading(),
        MessagesLoaded(
          conversations: tConversationsPage1,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: false,
        ),
        MessagesLoaded(
          conversations: tConversationsPage1,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: true,
        ),
        MessagesLoaded(
          conversations: [...tConversationsPage1, ...tConversationsPage2],
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.all,
            query: '',
            limit: Constants.pageSize,
            offset: 0,
          ),
        ).called(1);
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.all,
            query: '',
            limit: Constants.pageSize,
            offset: Constants.pageSize,
          ),
        ).called(1);
      },
    );

    blocTest<MessagesBloc, MessagesState>(
      'emits [isLoadingMore: true, isLoadingMore: false] and keeps original list when repository throws error',
      build: () {
        when(
          () => mockRepository.getConversations(
            filter: any(named: 'filter'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('Load more failure'));
        return messagesBloc;
      },
      seed: () => MessagesLoaded(
        conversations: tConversations,
        filter: ConversationFilter.all,
        searchQuery: '',
        hasMore: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreConversations()),
      expect: () => [
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: true,
        ),
        MessagesLoaded(
          conversations: tConversations,
          filter: ConversationFilter.all,
          searchQuery: '',
          hasMore: true,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.getConversations(
            filter: ConversationFilter.all,
            query: '',
            limit: Constants.pageSize,
            offset: tConversations.length,
          ),
        ).called(1);
      },
    );
  });
}
