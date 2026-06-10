import 'package:bloc/bloc.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessageRepository _repository;

  MessagesBloc({required MessageRepository repository})
    : _repository = repository,
      super(const MessagesInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<FilterConversations>(_onFilterConversations);
    on<LoadMoreConversations>(_onLoadMoreConversations);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<MessagesState> emit,
  ) async {
    await _fetchAndEmitConversations(
      filter: ConversationFilter.all,
      query: '',
      emit: emit,
      showLoading: true,
    );
  }

  Future<void> _onFilterConversations(
    FilterConversations event,
    Emitter<MessagesState> emit,
  ) async {
    final current = state;
    final query =
        event.query ?? (current is MessagesLoaded ? current.searchQuery : '');

    await _fetchAndEmitConversations(
      filter: event.filter,
      query: query,
      emit: emit,
      showLoading: true,
    );
  }

  Future<void> _onLoadMoreConversations(
    LoadMoreConversations event,
    Emitter<MessagesState> emit,
  ) async {
    final current = state;
    if (current is! MessagesLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final newPage = await _repository.getConversations(
        filter: current.filter,
        query: current.searchQuery,
        limit: Constants.pageSize,
        offset: current.conversations.length,
      );

      emit(
        current.copyWith(
          conversations: [...current.conversations, ...newPage],
          isLoadingMore: false,
          hasMore: newPage.length == Constants.pageSize,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _fetchAndEmitConversations({
    required ConversationFilter filter,
    required String query,
    required Emitter<MessagesState> emit,
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(const MessagesLoading());
    }
    try {
      final conversationsList = await _repository.getConversations(
        filter: filter,
        query: query,
        limit: Constants.pageSize,
        offset: 0,
      );
      emit(
        MessagesLoaded(
          conversations: conversationsList,
          filter: filter,
          searchQuery: query,
          hasMore: conversationsList.length == Constants.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }
}
