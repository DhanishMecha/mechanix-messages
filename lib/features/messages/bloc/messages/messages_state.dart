import 'package:equatable/equatable.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';
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
  /// The list of conversations.
  final List<ConversationModel> conversations;

  final ConversationFilter filter;

  final String searchQuery;

  final bool hasMore;

  final bool isLoadingMore;

  final bool isSelectionModeActive;

  final Set<int> selectedConversationIds;

  const MessagesLoaded({
    required this.conversations,
    this.filter = ConversationFilter.all,
    this.searchQuery = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isSelectionModeActive = false,
    this.selectedConversationIds = const {},
  });

  MessagesLoaded copyWith({
    List<ConversationModel>? conversations,
    ConversationFilter? filter,
    String? searchQuery,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSelectionModeActive,
    Set<int>? selectedConversationIds,
  }) {
    return MessagesLoaded(
      conversations: conversations ?? this.conversations,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSelectionModeActive: isSelectionModeActive ?? this.isSelectionModeActive,
      selectedConversationIds: selectedConversationIds ?? this.selectedConversationIds,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    filter,
    searchQuery,
    hasMore,
    isLoadingMore,
    isSelectionModeActive,
    selectedConversationIds,
  ];
}

class MessagesError extends MessagesState {
  final MessagesErrorType errorType;

  const MessagesError(this.errorType);

  @override
  List<Object?> get props => [errorType];
}
