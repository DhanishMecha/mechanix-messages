import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_entity.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';

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
  final ConversationErrorType errorType;

  const ConversationError(this.errorType);

  @override
  List<Object?> get props => [errorType];
}

class ComposeContactsLoading extends ConversationState {
  const ComposeContactsLoading();
}

class ComposeContactsLoaded extends ConversationState {
  final List<ContactEntity> contacts;

  final String searchQuery;

  final bool hasMore;

  final bool isLoadingMore;

  const ComposeContactsLoaded({
    required this.contacts,
    this.searchQuery = '',
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ComposeContactsLoaded copyWith({
    List<ContactEntity>? contacts,
    String? searchQuery,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ComposeContactsLoaded(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [contacts, searchQuery, hasMore, isLoadingMore];
}

class ComposeContactsError extends ConversationState {
  final ConversationErrorType errorType;

  const ComposeContactsError(this.errorType);

  @override
  List<Object?> get props => [errorType];
}
