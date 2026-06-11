import 'package:flutter/material.dart';
import 'package:mechanix_messages/core/utils/colors.dart';

class AppTheme {
  static final dark = ThemeData.dark(useMaterial3: true).copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: ThemeData.dark(useMaterial3: true).textTheme.copyWith(
      titleLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: AppColors.titleColor,
      ),
      titleMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.titleColor,
      ),
      titleSmall: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.titleColor,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.titleColor,
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.timeLabelColor,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.timeLabelColor,
      ),
    ).apply(fontFamily: "Sora"),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.linux: CupertinoPageTransitionsBuilder()},
    ),
    scrollbarTheme: const ScrollbarThemeData(
      radius: Radius.circular(4),
      thickness: WidgetStatePropertyAll(4),
      thumbColor: WidgetStatePropertyAll(AppColors.timeLabelColor),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
  );

  static final light = ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: ThemeData.light(useMaterial3: true).textTheme.copyWith(
      titleLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        color: AppColors.titleColor,
      ),
      titleMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.titleColor,
      ),
      titleSmall: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.titleColor,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.titleColor,
      ),
      bodySmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.timeLabelColor,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.timeLabelColor,
      ),
    ).apply(fontFamily: "Sora"),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.linux: CupertinoPageTransitionsBuilder()},
    ),
    scrollbarTheme: const ScrollbarThemeData(
      radius: Radius.circular(4),
      thickness: WidgetStatePropertyAll(4),
      thumbColor: WidgetStatePropertyAll(AppColors.timeLabelColor),
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
  );
}
