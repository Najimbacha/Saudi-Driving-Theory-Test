import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/modern_theme.dart';
import 'core/routes/app_router.dart';
import 'state/app_state.dart';

/// ROOT FIX: Removed dual localization state management
/// EasyLocalization (context.locale) is the single source of truth for locale
/// It handles persistence automatically via saveLocale: true in main.dart
/// Riverpod state no longer duplicates languageCode
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sharedPrefsProvider);
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'app.name'.tr(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ModernTheme.lightTheme,
      darkTheme: ModernTheme.darkTheme, // New Glassmorphism Theme
      themeMode: settings.themeMode,
      // ROOT FIX: Use context.locale directly - single source of truth
      // EasyLocalization's InheritedWidget updates this automatically
      // when context.setLocale() is called in settings
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
