import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/widgets/avatar.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/data/models/conversation_model.dart';
import 'package:mechanix_messages/features/messages/data/models/enums.dart';

class MessagesCard extends StatelessWidget {
  final ConversationModel conversation;

  const MessagesCard({super.key, required this.conversation});

  void _onCardTap(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.conversation,
      arguments: conversation,
    ).then((_) {
      if (context.mounted) {
        context.read<MessagesBloc>().add(const LoadConversations());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contact = conversation.contact;
    final name = contact?.name ?? conversation.phoneNumber;
    final initials = getInitials(name);

    final lastMsg = conversation.lastMessage;
    final hasUnread = conversation.hasUnread;

    return Column(
      children: [
        InkWell(
          onTap: () => _onCardTap(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Avatar(initials: initials, hasUnread: hasUnread),
                const SizedBox(width: 14),

                // Name + preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.contactName,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (lastMsg != null)
                            Text(
                              formatTime(lastMsg.createdAt, l10n),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.20,
                                fontWeight: FontWeight.w300,
                                color: AppColors.timeLabelColor,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Image.asset(
                            AppIcons.arrowRight,
                            width: 20,
                            height: 20,
                            color: AppColors.contactName,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (lastMsg != null)
                        Text(
                          '${lastMsg.messageDirection == MessageDirection.outgoing ? l10n.youPrefix : ""}${lastMsg.body}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.timeLabelColor,
                            fontWeight: FontWeight.normal,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.dividerColor),
      ],
    );
  }
}
