import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';
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
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime dt) {
    final dateStr = DateFormat('d MMM yyyy').format(dt);
    final timeStr = DateFormat('h:mm a').format(dt);
    return '$dateStr at $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ConversationLoaded) {
          _scrollToBottom();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[index];
          final isOutgoing =
              message.messageDirection == MessageDirection.outgoing;

          bool showDateHeader = false;
          if (index == 0) {
            showDateHeader = true;
          } else {
            final prevMessage = widget.messages[index - 1];
            showDateHeader = !_isSameDay(
              prevMessage.createdAt,
              message.createdAt,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDateHeader)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    _formatDateHeader(message.createdAt),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.timeLabelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              MessageBubble(message: message, isOutgoing: isOutgoing),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
