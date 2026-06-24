import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all conversations on screen init.
class LoadConversations extends MessagesEvent {
  const LoadConversations();
}

/// Filter and/or search conversations.
class FilterConversations extends MessagesEvent {
  final ConversationFilter filter;
  final String? query;

  const FilterConversations(this.filter, {this.query});

  @override
  List<Object?> get props => [filter, query];
}

/// Load the next page of conversations.
class LoadMoreConversations extends MessagesEvent {
  const LoadMoreConversations();
}
