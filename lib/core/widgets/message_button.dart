import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';

class MessageButton extends StatelessWidget {
  const MessageButton({
    super.key,
    required this.iconPath,
    this.isSelected = false,
    required this.onTap,
    double? boxSize,
    double? size,
    this.iconSize = 28,
    this.iconColor,
    this.bgColor,
    this.borderRadius = 8,
    this.border,
  }) : boxSize = size ?? boxSize ?? 44;

  final String iconPath;
  final bool isSelected;
  final VoidCallback? onTap;
  final double boxSize;
  final double iconSize;
  final Color? iconColor;
  final Color? bgColor;
  final double borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final borderVal = border;
    BorderSide borderSide = BorderSide.none;
    if (borderVal is Border) {
      borderSide = borderVal.top;
    }

    return IconButton(
      onPressed: onTap,
      iconSize: iconSize,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: boxSize, height: boxSize),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          bgColor ?? (isSelected ? AppColors.borderColor : Colors.transparent),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0x1AFFFFFF);
          }
          return Colors.transparent;
        }),
      ),
      icon: Image.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
        color: onTap == null
            ? AppColors.titleColor.withValues(alpha: 0.3)
            : (iconColor ?? (isSelected ? Colors.white : AppColors.titleColor)),
      ),
    );
  }
}
