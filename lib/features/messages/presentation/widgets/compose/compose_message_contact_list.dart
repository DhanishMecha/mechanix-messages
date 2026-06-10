import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/presentation/widgets/compose/compose_contact_tile.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

class ComposeMessageContactList extends StatefulWidget {
  const ComposeMessageContactList({super.key});

  @override
  State<ComposeMessageContactList> createState() => _ComposeMessageContactListState();
}

class _ComposeMessageContactListState extends State<ComposeMessageContactList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ConversationBloc>().add(const LoadMoreComposeContacts());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        if (state is ComposeContactsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.fabBg),
          );
        } else if (state is ComposeContactsError) {
          return Center(
            child: Text(
              getErrorMessage(context, state.errorType),
              style: const TextStyle(
                color: AppColors.placeholderColor,
                fontSize: 16,
              ),
            ),
          );
        } else if (state is ComposeContactsLoaded) {
          final contacts = state.contacts;
          final searchQuery = state.searchQuery;
          if (contacts.isEmpty) {
            return Center(
              child: Text(
                searchQuery.isEmpty
                    ? l10n.noContactsFound
                    : l10n.noMatchingContacts,
                style: const TextStyle(
                  color: AppColors.placeholderColor,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: contacts.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.dividerColor, height: 1),
            itemBuilder: (context, index) {
              if (index >= contacts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.fabBg,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final contact = contacts[index];
              return ComposeContactTile(contact: contact);
            },
          );
        }
        return Container();
      },
    );
  }
}
