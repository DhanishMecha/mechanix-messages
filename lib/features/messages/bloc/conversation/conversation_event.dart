import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversation extends ConversationEvent {
  final int conversationId;

  const LoadConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ConversationEvent {
  final String body;

  const SendMessage(this.body);

  @override
  List<Object?> get props => [body];
}

class LoadMoreMessages extends ConversationEvent {
  const LoadMoreMessages();
}
