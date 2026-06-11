import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_list/messages_card.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({super.key});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        final blocState = context.read<MessagesBloc>().state;
        if (blocState is MessagesLoaded) {
          if (blocState.hasMore && !blocState.isLoadingMore) {
            context.read<MessagesBloc>().add(const LoadMoreConversations());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      builder: (context, state) {
        if (state is MessagesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          );
        }

        if (state is MessagesError) {
          return Center(
            child: Text(
              getMessagesErrorMessage(context, state.errorType),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.redAccent,
              ),
            ),
          );
        }

        if (state is MessagesLoaded) {
          final conversations = state.conversations;
          final isLoadingMore = state.isLoadingMore;

          if (conversations.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noMessages,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: conversations.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == conversations.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white38,
                    ),
                  ),
                );
              }

              return MessagesCard(
                key: ValueKey(conversations[index].id),
                conversation: conversations[index],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
