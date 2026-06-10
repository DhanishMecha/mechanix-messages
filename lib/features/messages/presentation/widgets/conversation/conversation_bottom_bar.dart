import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/constants.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      maxLength: Constants.maxMessageLength,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.titleColor,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.writeMessage,
                        counter: const SizedBox.shrink(),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.placeholderColor,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
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
            iconSize: 24,
            onTap: _handleSubmit,
            bgColor: AppColors.contactName,
            iconColor: AppColors.bottomBarBg,
          ),
        ],
      ),
    );
  }
}
