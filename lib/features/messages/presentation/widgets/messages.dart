import 'package:flutter/material.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_list/messages_list.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_search/messages_search_bar.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: MessagesSearchBar(),
        ),
        Expanded(child: MessagesList()),
      ],
    );
  }
}
