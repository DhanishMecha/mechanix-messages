import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/features/messages/data/models/message_model.dart';

class MessageBubble extends StatefulWidget {
  final MessageEntity message;
  final bool isOutgoing;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOutgoing,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showTime = false;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(widget.message.createdAt);

    return Align(
      alignment: widget.isOutgoing
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showTime = !_showTime;
          });
        },
        child: Column(
          crossAxisAlignment: widget.isOutgoing
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bottomBarBg,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: Text(
                widget.message.body,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.titleColor,
                  height: 1.4,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Container(
                height: _showTime ? null : 0,
                padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.timeLabelColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
