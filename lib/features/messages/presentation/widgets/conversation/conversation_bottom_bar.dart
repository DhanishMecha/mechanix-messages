import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/utils/message_button.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';

class ConversationBottomBar extends StatefulWidget {
  const ConversationBottomBar({super.key});

  @override
  State<ConversationBottomBar> createState() => _ConversationBottomBarState();
}

class _ConversationBottomBarState extends State<ConversationBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ConversationBloc>().add(SendMessage(text));
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          // Plus Add Button
          MessageButton(
            iconPath: AppIcons.add,
            onTap: () {
              // Action for + button (e.g. attachments, photos)
            },
            bgColor: Colors.transparent,
            border: Border.all(color: Colors.transparent),
            iconColor: AppColors.titleColor,
          ),
          const SizedBox(width: 12),

          // Input field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.titleColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.placeholderColor,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button
          MessageButton(
            iconPath: AppIcons.send,
            onTap: _handleSubmit,
            bgColor: AppColors.contactName,
            iconColor: AppColors.bottomBarBg,
          ),
        ],
      ),
    );
  }
}
