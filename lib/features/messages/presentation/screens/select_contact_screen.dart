import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/core/widgets/avatar.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';

class SelectContactScreen extends StatefulWidget {
  const SelectContactScreen({super.key});

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactEntity> _allContacts = [];
  List<ContactEntity> _filteredContacts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    try {
      final box = ContactsStoreService.contacts;
      final list = box.query().build().find();
      // Sort alphabetically by name
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _allContacts = list;
        _filteredContacts = list;
      });
    } catch (_) {
      // Handle empty or uninitialized database gracefully
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _searchQuery = _searchController.text.trim();
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          final nameMatch = contact.name.toLowerCase().contains(query);
          final phoneMatch = contact.phoneNumbers.any(
            (p) => p.number.toLowerCase().contains(query),
          );
          return nameMatch || phoneMatch;
        }).toList();
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
    final showDirectSend =
        _searchQuery.isNotEmpty &&
        !_filteredContacts.any(
          (c) => c.phoneNumbers.any((p) => p.number == _searchQuery),
        );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Image.asset(
            AppIcons.arrowLeft,
            width: 20,
            height: 20,
            color: AppColors.titleColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New message',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.titleColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
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
                      child: _searchQuery.isEmpty
                          ? const Text(
                              'To: ',
                              style: TextStyle(
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
                      decoration: const InputDecoration(
                        hintText: 'Search or enter phone number',
                        hintStyle: TextStyle(
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
                      child: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: Image.asset(
                                AppIcons.close,
                                width: 20,
                                height: 20,
                                color: AppColors.placeholderColor,
                              ),
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.placeholderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  AppIcons.add,
                                  width: 10,
                                  height: 10,
                                  color: AppColors.placeholderColor,
                                ),
                              ),
                            ),
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
                'Send message to $_searchQuery',
                style: const TextStyle(
                  color: AppColors.titleColor,
                  fontSize: 18,
                ),
              ),
              onTap: () => _startConversation(_searchQuery),
            ),
            const Divider(color: AppColors.dividerColor, height: 1),
          ],

          // Contacts List
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No contacts found'
                          : 'No matching contacts',
                      style: const TextStyle(
                        color: AppColors.placeholderColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      final name = contact.name;
                      final initials = getInitials(name);

                      // Get first phone number or fallback
                      final phoneNumber = contact.phoneNumbers.isNotEmpty
                          ? contact.phoneNumbers.first.number
                          : 'No number';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Avatar(initials: initials),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleColor,
                          ),
                        ),
                        subtitle: Text(
                          phoneNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.subtitleColor,
                          ),
                        ),
                        onTap: () {
                          if (contact.phoneNumbers.isNotEmpty) {
                            _startConversation(
                              contact.phoneNumbers.first.number,
                            );
                          } else {
                            // If no number saved, fallback to using name as identifier
                            _startConversation(contact.name);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
