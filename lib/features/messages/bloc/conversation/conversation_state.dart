import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationLoaded extends ConversationState {
  final ConversationEntity conversation;
  final List<MessageEntity> messages;
  final bool hasMore;
  final bool isLoadingMore;

  const ConversationLoaded({
    required this.conversation,
    required this.messages,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ConversationLoaded copyWith({
    ConversationEntity? conversation,
    List<MessageEntity>? messages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ConversationLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [conversation, messages, hasMore, isLoadingMore];
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}
