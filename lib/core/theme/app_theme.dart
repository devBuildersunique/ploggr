import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'app_tokens.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    fontFamily: 'NunitoSans',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    ),
    textTheme: const TextTheme(
      headlineLarge: AppText.hero,
      headlineSmall: AppText.title,
      titleLarge: AppText.heading,
      titleMedium: AppText.label,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.caption,
    ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'NunitoSans',
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
        textStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFAFCF9),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: AppColors.muted, fontSize: 14),
      prefixIconColor: AppColors.primary,
      border: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.forest,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
    ),
  );
}
