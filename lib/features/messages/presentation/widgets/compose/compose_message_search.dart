import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/widgets/avatar.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_bloc.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_event.dart';
import 'package:mechanix_messages/features/messages/bloc/conversation/conversation_state.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

class ComposeMessageSearch extends StatefulWidget {
  const ComposeMessageSearch({super.key});

  @override
  State<ComposeMessageSearch> createState() => _ComposeMessageSearchState();
}

class _ComposeMessageSearchState extends State<ComposeMessageSearch> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    final query = _searchController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<ConversationBloc>().add(LoadComposeContacts(query: query));
      }
    });
  }

  Future<void> _startConversation(String phoneNumber) async {
    final repository = context.read<MessageRepositoryImpl>();
    final conversation = await repository.getOrCreateConversation(phoneNumber);

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.conversation,
        arguments: conversation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _searchController.text.trim();

    return BlocSelector<
      ConversationBloc,
      ConversationState,
      List<ContactEntity>
    >(
      selector: (state) => state is ComposeContactsLoaded
          ? state.contacts
          : const <ContactEntity>[],
      builder: (context, contactsList) {
        final showDirectSend =
            query.isNotEmpty &&
            !contactsList.any(
              (c) => c.phoneNumbers.any((p) => p.number == query),
            );

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.searchBarBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: query.isEmpty
                            ? Text(
                                l10n.toLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.placeholderColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : Image.asset(
                                AppIcons.search,
                                width: 20,
                                height: 20,
                                color: AppColors.placeholderColor,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('search_text_field'),
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.titleColor,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.searchOrEnterPhone,
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: AppColors.placeholderColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                },
                                child: Image.asset(
                                  AppIcons.close,
                                  width: 20,
                                  height: 20,
                                  color: AppColors.placeholderColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Direct Send Option
            if (showDirectSend) ...[
              ListTile(
                leading: const Avatar(initials: '#'),
                title: Text(
                  l10n.sendMessageTo(query),
                  style: const TextStyle(
                    color: AppColors.titleColor,
                    fontSize: 18,
                  ),
                ),
                onTap: () => _startConversation(query),
              ),
              const Divider(color: AppColors.dividerColor, height: 1),
            ],
          ],
        );
      },
    );
  }
}
