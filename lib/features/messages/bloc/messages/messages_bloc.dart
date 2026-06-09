import 'package:bloc/bloc.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final MessageRepository _repository;

  MessagesBloc({required MessageRepository repository})
      : _repository = repository,
        super(const MessagesInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<FilterConversations>(_onFilterConversations);
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<MessagesState> emit,
  ) async {
    emit(const MessagesLoading());
    try {
      final conversations = await _repository.getConversations();
      emit(MessagesLoaded(
        allConversations: conversations,
        displayedConversations: conversations,
      ));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  void _onFilterConversations(
    FilterConversations event,
    Emitter<MessagesState> emit,
  ) {
    final current = state;
    if (current is! MessagesLoaded) return;

    final filtered = _applyFilter(
      current.allConversations,
      event.filter,
      current.searchQuery,
    );

    emit(current.copyWith(
      filter: event.filter,
      displayedConversations: filtered,
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<MessagesState> emit,
  ) {
    final current = state;
    if (current is! MessagesLoaded) return;

    final filtered = _applyFilter(
      current.allConversations,
      current.filter,
      event.query,
    );

    emit(current.copyWith(
      searchQuery: event.query,
      displayedConversations: filtered,
    ));
  }

  List<ConversationEntity> _applyFilter(
    List<ConversationEntity> all,
    ConversationFilter filter,
    String query,
  ) {
    var result = all;

    if (filter == ConversationFilter.unread) {
      result = result.where((c) {
        return c.messages.any(
          (m) => m.readAt == null,
        );
      }).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((c) {
        final contactName =
            c.phone.target?.contact.target?.name.toLowerCase() ?? '';
        final phone = c.phoneNumber.toLowerCase();
        final lastMsg =
            c.messages.isNotEmpty ? c.messages.last.body.toLowerCase() : '';
        return contactName.contains(q) ||
            phone.contains(q) ||
            lastMsg.contains(q);
      }).toList();
    }

    return result;
  }
}
