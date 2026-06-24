import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_contacts/mechanix_contacts.dart';
import 'package:mechanix_messages/core/utils/app_logger.dart';
import 'package:mechanix_messages/core/utils/app_routes.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/helpers.dart';
import 'package:mechanix_messages/core/widgets/avatar.dart';
import 'package:mechanix_messages/features/messages/data/repository/message_repository_impl.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

class ComposeContactTile extends StatelessWidget {
  final ContactEntity contact;

  const ComposeContactTile({super.key, required this.contact});

  Future<void> _startConversation(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      final repository = context.read<MessageRepositoryImpl>();
      final conversation = await repository.getOrCreateConversation(
        phoneNumber,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.conversation,
          arguments: conversation,
        );
      }
    } catch (e, st) {
      AppLogger.e('ComposeContactTile: failed to start conversation', error: e, stack: st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorUnknown)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = contact.name;
    final initials = getInitials(name);

    // Get first phone number or fallback
    final phoneNumber = contact.phoneNumbers.isNotEmpty
        ? contact.phoneNumbers.first.number
        : l10n.noNumber;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Avatar(initials: initials),
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        phoneNumber,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.subtitleColor,
        ),
      ),
      onTap: () {
        if (contact.phoneNumbers.isNotEmpty) {
          _startConversation(context, contact.phoneNumbers.first.number);
        } else {
          // If no number saved, fallback to using name as identifier
          _startConversation(context, contact.name);
        }
      },
    );
  }
}
