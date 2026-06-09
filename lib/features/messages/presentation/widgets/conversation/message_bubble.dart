import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isOutgoing;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isOutgoing ? AppColors.bottomBarBg : AppColors.filterBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isOutgoing ? 16 : 0),
            bottomRight: Radius.circular(isOutgoing ? 0 : 16),
          ),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Text(
          message.body,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.titleColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
