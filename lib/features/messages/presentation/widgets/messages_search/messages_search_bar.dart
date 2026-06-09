import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/messages/messages_event.dart';

class MessagesSearchBar extends StatefulWidget {
  const MessagesSearchBar({super.key});

  @override
  State<MessagesSearchBar> createState() => _MessagesSearchBarState();
}

class _MessagesSearchBarState extends State<MessagesSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.titleColor,
              ),
              decoration: const InputDecoration(
                hintText: 'Search in messages',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.placeholderColor,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                context
                    .read<MessagesBloc>()
                    .add(SearchQueryChanged(value.trim()));
              },
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}
