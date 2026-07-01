import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/widgets/message_button.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/delete_confirm_bottom_sheet.dart';

class MessagesBottomBar extends StatelessWidget {
  const MessagesBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomBarBg,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MessageButton(
                iconPath: AppIcons.close,
                iconSize: 24,
                onTap: () {
                  context.read<MessagesBloc>().add(
                    const ClearConversationSelection(),
                  );
                },
              ),
              MessageButton(
                iconPath: AppIcons.delete,
                iconColor: Colors.redAccent,
                iconSize: 24,
                onTap: () {
                  final state = context.read<MessagesBloc>().state;
                  final count = state is MessagesLoaded
                      ? state.selectedConversationIds.length
                      : 0;
                  _showDeleteConfirmBottomSheet(context, count);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmBottomSheet(BuildContext context, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bottomBarBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DeleteConfirmBottomSheet(count: count),
    );
  }
}
