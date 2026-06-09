import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesTopbar extends StatelessWidget {
  const MessagesTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (prev, curr) {
        if (prev is MessagesLoaded && curr is MessagesLoaded) {
          return prev.filter != curr.filter;
        }
        return false;
      },
      builder: (context, state) {
        final filter = state is MessagesLoaded
            ? state.filter
            : ConversationFilter.all;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: AppColors.titleColor,
                height: 1.20,
              ),
            ),
            _FilterToggle(current: filter),
          ],
        );
      },
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final ConversationFilter current;

  const _FilterToggle({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.filterBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(
            label: 'All',
            isActive: current == ConversationFilter.all,
            onTap: () => context.read<MessagesBloc>().add(
                  const FilterConversations(ConversationFilter.all),
                ),
          ),
          _Tab(
            label: 'Unread',
            isActive: current == ConversationFilter.unread,
            onTap: () => context.read<MessagesBloc>().add(
                  const FilterConversations(ConversationFilter.unread),
                ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.filterActiveBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight:  FontWeight.w400,
            color: isActive
                ? AppColors.filterActiveText
                : AppColors.filterInactiveText,
          ),
        ),
      ),
    );
  }
}