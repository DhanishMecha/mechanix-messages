import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/enums.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_state.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

class MessagesSearchBar extends StatefulWidget {
  const MessagesSearchBar({super.key});

  @override
  State<MessagesSearchBar> createState() => _MessagesSearchBarState();
}

class _MessagesSearchBarState extends State<MessagesSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final state = context.read<MessagesBloc>().state;
        final currentFilter = state is MessagesLoaded
            ? state.filter
            : ConversationFilter.all;
        context.read<MessagesBloc>().add(
          FilterConversations(currentFilter, query: value.trim()),
        );
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Image.asset(
            AppIcons.search,
            width: 24,
            height: 24,
            color: AppColors.contactName,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 20, color: AppColors.titleColor),
              decoration: InputDecoration(
                hintText: l10n.searchInMessages,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.placeholderColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
