import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_list/messages_card.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

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
              state.message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          );
        }

        if (state is MessagesLoaded) {
          final conversations = state.displayedConversations;

          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'No messages',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: conversations.length,
            itemBuilder: (context, index) {
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
