import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessageRepository _repository;

  ConversationBloc({required MessageRepository repository})
    : _repository = repository,
      super(const ConversationInitial()) {
    on<LoadConversation>(_onLoadConversation);
    on<SendMessage>(_onSendMessage);
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
        emit(const ConversationError("Conversation not found"));
        return;
      }

      final messages = List<MessageEntity>.from(conversation.messages)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      emit(ConversationLoaded(conversation: conversation, messages: messages));
    } catch (e) {
      emit(ConversationError(e.toString()));
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
      await _repository.insertMessage(
        phoneNumber,
        event.body,
        MessageDirection.outgoing,
      );

      final updated = await _repository.getConversationById(
        current.conversation.id,
      );
      if (updated != null) {
        final messages = List<MessageEntity>.from(updated.messages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        emit(ConversationLoaded(conversation: updated, messages: messages));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}
