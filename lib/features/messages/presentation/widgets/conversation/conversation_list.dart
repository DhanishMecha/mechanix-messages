import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/models/message_entity.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/conversation/message_bubble.dart';

class ConversationList extends StatefulWidget {
  final List<MessageEntity> messages;

  const ConversationList({super.key, required this.messages});

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
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
        final blocState = context.read<ConversationBloc>().state;
        if (blocState is ConversationLoaded) {
          if (blocState.hasMore && !blocState.isLoadingMore) {
            context.read<ConversationBloc>().add(const LoadMoreMessages());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocState = context.read<ConversationBloc>().state;
    final isLoadingMore = blocState is ConversationLoaded
        ? blocState.isLoadingMore
        : false;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.messages.length) {
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

        final message = widget.messages[index];
        final isOutgoing =
            message.messageDirection == MessageDirection.outgoing;

        bool showDateHeader = false;
        if (index == widget.messages.length - 1) {
          showDateHeader = true; // Always show first message date header
        } else {
          final nextMessage = widget.messages[index + 1];
          showDateHeader = !isSameDay(nextMessage.createdAt, message.createdAt);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDateHeader) _DateHeader(dateTime: message.createdAt),
            MessageBubble(message: message, isOutgoing: isOutgoing),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime dateTime;

  const _DateHeader({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Text(
        formatDateHeader(dateTime, l10n),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
