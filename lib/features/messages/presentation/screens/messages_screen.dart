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
    return BlocSelector<MessagesBloc, MessagesState, bool>(
      selector: (state) =>
          state is MessagesLoaded && state.isSelectionModeActive,
      builder: (context, isSelectionModeActive) {
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
