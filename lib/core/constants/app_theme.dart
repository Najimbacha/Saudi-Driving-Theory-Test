import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.tertiary,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightSurface2,
      outline: AppColors.lightOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkText,
      inversePrimary: AppColors.primaryContainer,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: _appBarTheme(scheme, isDark: false),
      bottomNavigationBarTheme: _bottomNavTheme(scheme, isDark: false),
      cardTheme: _cardTheme(scheme, isDark: false),
      tabBarTheme: _tabBarTheme(scheme),
      chipTheme: _chipTheme(scheme, isDark: false),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.8),
        thickness: 1,
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryContainer, // brighter for dark UI accents
      onPrimary: AppColors.primary,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.secondaryContainer,
      onSecondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: Colors.white,
      tertiary: AppColors.tertiaryContainer,
      onTertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiary,
      onTertiaryContainer: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurface2,
      outline: AppColors.darkOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightText,
      inversePrimary: AppColors.primary,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: _appBarTheme(scheme, isDark: true),
      bottomNavigationBarTheme: _bottomNavTheme(scheme, isDark: true),
      cardTheme: _cardTheme(scheme, isDark: true),
      tabBarTheme: _tabBarTheme(scheme),
      chipTheme: _chipTheme(scheme, isDark: true),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.9),
        thickness: 1,
      ),
    );
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );

    return base.copyWith(
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      textButtonTheme: _textButtonTheme(scheme),
      inputDecorationTheme: _inputTheme(scheme),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withValues(alpha: 0.9),
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      ),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme scheme, {required bool isDark}) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    );
  }

  static CardThemeData _cardTheme(ColorScheme scheme, {required bool isDark}) {
    return CardThemeData(
      color: scheme.surfaceContainerHighest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outline.withValues(alpha: isDark ? 0.9 : 0.8)),
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(
    ColorScheme scheme, {
    required bool isDark,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurface.withValues(alpha: 0.55),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
    );
  }

  static TabBarThemeData _tabBarTheme(ColorScheme scheme) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.65),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: scheme.outline.withValues(alpha: 0.7),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme, {required bool isDark}) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primaryContainer,
      disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: scheme.outline.withValues(alpha: isDark ? 0.9 : 0.8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55)),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
    );
  }
}
