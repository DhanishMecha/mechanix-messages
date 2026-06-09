import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/utils/message_button.dart';

class MessagesFloatingButton extends StatelessWidget {
  const MessagesFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageButton(
      iconPath: AppIcons.edit,
      onTap: () {
        // TODO: navigate to new message / compose screen
      },
      size: 60,
      iconSize: 32,
      borderRadius: 14,
      bgColor: AppColors.fabBg,
    );
  }
}
