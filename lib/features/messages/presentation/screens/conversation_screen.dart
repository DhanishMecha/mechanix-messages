import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_entity.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/conversation.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/conversation/conversation_bottom_bar.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/conversation/conversation_top_bar.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversation =
        ModalRoute.of(context)!.settings.arguments as ConversationEntity;

    return BlocProvider<ConversationBloc>(
      create: (context) =>
          ConversationBloc(repository: context.read<MessageRepositoryImpl>())
            ..add(LoadConversation(conversation.id)),
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                context.read<MessagesBloc>().add(const LoadConversations());
              }
            },
            child: Scaffold(
              appBar: ConversationTopBar(conversation: conversation),
              body: const Conversation(),
              bottomNavigationBar: const ConversationBottomBar(),
            ),
          );
        },
      ),
    );
  }
}
