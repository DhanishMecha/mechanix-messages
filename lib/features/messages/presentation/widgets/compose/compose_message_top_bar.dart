import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';
import 'package:mechanix_messages/core/utils/icons.dart';
import 'package:mechanix_messages/l10n/app_localizations.dart';

class ComposeMessageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeMessageTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
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
      title: Text(
        l10n.newMessage,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.titleColor,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
