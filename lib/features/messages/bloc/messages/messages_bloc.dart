import 'package:bloc/bloc.dart';
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
    final query = current is MessagesLoaded ? current.searchQuery : '';

    await _fetchAndEmitConversations(
      filter: event.filter,
      query: query,
      emit: emit,
      showLoading: true,
    );
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
      final conversations = await _repository.getConversations(
        filter: filter,
        query: query,
      );
      emit(
        MessagesLoaded(
          allConversations: conversations,
          displayedConversations: conversations,
          filter: filter,
          searchQuery: query,
        ),
      );
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }
}
