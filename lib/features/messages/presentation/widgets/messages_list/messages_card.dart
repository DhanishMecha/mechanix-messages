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
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
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

  void _handleTap(BuildContext context) {
    final messagesBloc = context.read<MessagesBloc>();
    final blocState = messagesBloc.state;
    if (blocState is MessagesLoaded && blocState.isSelectionModeActive) {
      messagesBloc.add(ToggleConversationSelection(conversation.id));
    } else {
      _onCardTap(context);
    }
  }

  void _handleLongPress(BuildContext context) {
    context.read<MessagesBloc>().add(
      ToggleConversationSelection(conversation.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contact = conversation.contact;
    final name = contact?.name ?? conversation.phoneNumber;
    final initials = getInitials(name);

    final lastMsg = conversation.lastMessage;
    final hasUnread = conversation.hasUnread;

    return BlocSelector<
      MessagesBloc,
      MessagesState,
      ({bool isActive, bool isSelected})
    >(
      selector: (state) {
        if (state is MessagesLoaded) {
          return (
            isActive: state.isSelectionModeActive,
            isSelected: state.selectedConversationIds.contains(conversation.id),
          );
        }
        return (isActive: false, isSelected: false);
      },
      builder: (context, cardState) {
        return Column(
          children: [
            Container(
              color: cardState.isSelected
                  ? AppColors.filterBg
                  : Colors.transparent,
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () => _handleTap(context),
                onLongPress: () => _handleLongPress(context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cardState.isActive) ...[
                        _SelectionIndicator(isSelected: cardState.isSelected),
                        const SizedBox(width: 14),
                      ],
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
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
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
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
            ),
            const Divider(height: 1, color: AppColors.dividerColor),
          ],
        );
      },
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.35),
          width: 1.8,
        ),
      ),
      child: isSelected
          ? const Center(
              child: Icon(
                Icons.check,
                color: AppColors.bottomBarBg,
                size: 14,
                weight: 3.0,
              ),
            )
          : null,
    );
  }
}
