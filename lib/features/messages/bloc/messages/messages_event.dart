import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/core/utils/enums.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all conversations on screen init.
class LoadConversations extends MessagesEvent {
  const LoadConversations();
}

/// Filter conversations by [All] or [Unread].
class FilterConversations extends MessagesEvent {
  final ConversationFilter filter;

  const FilterConversations(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Update the search query string.
class SearchQueryChanged extends MessagesEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

