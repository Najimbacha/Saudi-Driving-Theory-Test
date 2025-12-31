// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightAccent,
      onPrimary: AppColors.lightAccentContrast,
      secondary: AppColors.lightSurface2,
      onSecondary: AppColors.lightText2,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      error: AppColors.lightDanger,
      onError: AppColors.lightAccentContrast,
    ),
    dividerColor: AppColors.lightDivider,
    cardColor: AppColors.lightSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.lightText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.lightText),
      bodySmall: TextStyle(color: AppColors.lightMuted),
      titleMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w700),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightAccent,
        foregroundColor: AppColors.lightAccentContrast,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightText,
        side: const BorderSide(color: AppColors.lightBorder),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkAccentContrast,
      secondary: AppColors.darkSurface2,
      onSecondary: AppColors.darkText2,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      error: AppColors.darkDanger,
      onError: AppColors.darkAccentContrast,
    ),
    dividerColor: AppColors.darkDivider,
    cardColor: AppColors.darkSurface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.darkText),
      bodySmall: TextStyle(color: AppColors.darkMuted),
      titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w700),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.darkAccentContrast,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: const BorderSide(color: AppColors.darkBorder),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),
    useMaterial3: true,
  );
}
