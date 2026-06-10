import 'package:flutter/material.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/compose/compose_message_contact_list.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/compose/compose_message_search.dart';

class ComposeMessage extends StatelessWidget {
  const ComposeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ComposeMessageSearch(),
        Expanded(
          child: ComposeMessageContactList(),
        ),
      ],
    );
  }
}
