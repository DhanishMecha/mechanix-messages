import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/utils/message_button.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';

class MessagesFloatingButton extends StatelessWidget {
  const MessagesFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageButton(
      iconPath: AppIcons.edit,
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.selectContact).then((_) {
          if (context.mounted) {
            context.read<MessagesBloc>().add(const LoadConversations());
          }
        });
      },
      size: 60,
      iconSize: 32,
      borderRadius: 14,
      bgColor: AppColors.fabBg,
    );
  }
}
