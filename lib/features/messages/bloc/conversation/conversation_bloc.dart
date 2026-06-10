import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mechanix_messages/core/utils/app_logger.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessageRepository _repository;

  ConversationBloc({required MessageRepository repository})
    : _repository = repository,
      super(const ConversationInitial()) {
    on<LoadConversation>(_onLoadConversation);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessage>(_onSendMessage);
    on<LoadComposeContacts>(_onLoadComposeContacts);
    on<LoadMoreComposeContacts>(_onLoadMoreComposeContacts);
  }

  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());
    try {
      await _repository.markAllAsRead(event.conversationId);
      final conversation = await _repository.getConversationById(
        event.conversationId,
      );
      if (conversation == null) {
        emit(const ConversationError(ConversationErrorType.notFound));
        return;
      }

      final messages = await _repository.getMessagesForConversation(
        event.conversationId,
        limit: Constants.pageSize,
        offset: 0,
      );

      emit(
        ConversationLoaded(
          conversation: conversation,
          messages: messages,
          hasMore: messages.length == Constants.pageSize,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to load conversation: ${event.conversationId}', error: e, stack: stack);
      emit(const ConversationError(ConversationErrorType.loadFailed));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ConversationState> emit,
  ) async {
    final current = state;
    if (current is! ConversationLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final newPage = await _repository.getMessagesForConversation(
        current.conversation.id,
        limit: Constants.pageSize,
        offset: current.messages.length,
      );

      emit(
        current.copyWith(
          messages: [...current.messages, ...newPage],
          isLoadingMore: false,
          hasMore: newPage.length == Constants.pageSize,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to load more messages', error: e, stack: stack);
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    final current = state;
    if (current is! ConversationLoaded) return;

    if (event.body.trim().isEmpty) return;

    try {
      final phoneNumber = current.conversation.phoneNumber;
      final message = await _repository.insertMessage(
        phoneNumber,
        event.body,
        MessageDirection.outgoing,
      );

      final updatedMessages = [message, ...current.messages];
      emit(current.copyWith(messages: updatedMessages));
    } catch (e, stack) {
      AppLogger.e('Failed to send message', error: e, stack: stack);
      emit(const ConversationError(ConversationErrorType.sendFailed));
    }
  }

  Future<void> _onLoadComposeContacts(
    LoadComposeContacts event,
    Emitter<ConversationState> emit,
  ) async {
    await _fetchAndEmitComposeContacts(
      query: event.query,
      emit: emit,
      showLoading: true,
    );
  }

  Future<void> _onLoadMoreComposeContacts(
    LoadMoreComposeContacts event,
    Emitter<ConversationState> emit,
  ) async {
    final current = state;
    if (current is! ComposeContactsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final newPage = await _repository.getContacts(
        query: current.searchQuery,
        limit: Constants.pageSize,
        offset: current.contacts.length,
      );

      emit(
        current.copyWith(
          contacts: [...current.contacts, ...newPage],
          isLoadingMore: false,
          hasMore: newPage.length == Constants.pageSize,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to load more compose contacts', error: e, stack: stack);
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _fetchAndEmitComposeContacts({
    required String query,
    required Emitter<ConversationState> emit,
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(const ComposeContactsLoading());
    }
    try {
      final contactsList = await _repository.getContacts(
        query: query,
        limit: Constants.pageSize,
        offset: 0,
      );
      emit(
        ComposeContactsLoaded(
          contacts: contactsList,
          searchQuery: query,
          hasMore: contactsList.length == Constants.pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to fetch compose contacts with query: $query', error: e, stack: stack);
      emit(const ComposeContactsError(ConversationErrorType.loadFailed));
    }
  }
}
