import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/conversation/conversation_list.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        if (state is ConversationLoading) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          );
        }

        if (state is ConversationError) {
          return Center(
            child: Text(
              getErrorMessage(context, state.errorType),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.redAccent,
              ),
            ),
          );
        }

        if (state is ConversationLoaded) {
          return ConversationList(messages: state.messages);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
