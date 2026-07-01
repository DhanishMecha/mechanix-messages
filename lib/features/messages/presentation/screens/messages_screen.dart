import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_floating_button.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_top_bar.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/messages_bottom_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (prev, curr) {
        final prevActive = prev is MessagesLoaded && prev.isSelectionModeActive;
        final currActive = curr is MessagesLoaded && curr.isSelectionModeActive;
        return prevActive != currActive;
      },
      builder: (context, state) {
        final isSelectionModeActive =
            state is MessagesLoaded && state.isSelectionModeActive;

        return Scaffold(
          appBar: AppBar(titleSpacing: 16, title: const MessagesTopbar()),
          floatingActionButton: isSelectionModeActive
              ? null
              : const MessagesFloatingButton(),
          body: const Messages(),
          bottomNavigationBar: isSelectionModeActive
              ? const MessagesBottomBar()
              : null,
        );
      },
    );
  }
}
