import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/widgets/avatar.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';

class ConversationTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ConversationEntity conversation;

  const ConversationTopBar({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final contact = conversation.phone.target?.contact.target;
    final name = contact?.name ?? conversation.phoneNumber;
    final initials = getInitials(name);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 8,
        left: 8,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Image.asset(
              AppIcons.arrowLeft,
              width: 20,
              height: 20,
              color: AppColors.titleColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          // Avatar
          Avatar(initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.titleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Image.asset(
            AppIcons.arrowRight,
            width: 20,
            height: 20,
            color: AppColors.titleColor,
          ),
        ],
      ),
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(60);
}
