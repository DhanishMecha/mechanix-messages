import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  /// Full unfiltered list fetched from the repository.
  final List<ConversationEntity> allConversations;

  /// Subset shown in the UI after applying [filter] and [searchQuery].
  final List<ConversationEntity> displayedConversations;

  final ConversationFilter filter;

  final String searchQuery;

  const MessagesLoaded({
    required this.allConversations,
    required this.displayedConversations,
    this.filter = ConversationFilter.all,
    this.searchQuery = '',
  });

  MessagesLoaded copyWith({
    List<ConversationEntity>? allConversations,
    List<ConversationEntity>? displayedConversations,
    ConversationFilter? filter,
    String? searchQuery,
  }) {
    return MessagesLoaded(
      allConversations: allConversations ?? this.allConversations,
      displayedConversations:
          displayedConversations ?? this.displayedConversations,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allConversations,
    displayedConversations,
    filter,
    searchQuery,
  ];
}

class MessagesError extends MessagesState {
  final String message;

  const MessagesError(this.message);

  @override
  List<Object?> get props => [message];
}
