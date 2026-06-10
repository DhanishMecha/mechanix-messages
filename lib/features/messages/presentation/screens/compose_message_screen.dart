import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/compose/compose_message.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/compose/compose_message_top_bar.dart';

class ComposeMessageScreen extends StatelessWidget {
  const ComposeMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConversationBloc(repository: context.read<MessageRepositoryImpl>())
            ..add(const LoadComposeContacts()),
      child: const Scaffold(
        backgroundColor: Colors.black,
        appBar: ComposeMessageTopBar(),
        body: ComposeMessage(),
      ),
    );
  }
}
