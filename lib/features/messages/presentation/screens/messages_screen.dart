import 'package:flutter/material.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_floating_button.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_top_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 16, title: const MessagesTopbar()),
      floatingActionButton: const MessagesFloatingButton(),
      body: const Messages(),
    );
  }
}
