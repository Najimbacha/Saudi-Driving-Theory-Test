import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/modern_theme.dart';
import 'core/routes/app_router.dart';
import 'state/app_state.dart';
import 'utils/app_fonts.dart';

/// ROOT FIX: Removed dual localization state management
/// EasyLocalization (context.locale) is the single source of truth for locale
/// It handles persistence automatically via saveLocale: true in main.dart
/// Riverpod state no longer duplicates languageCode
class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  String _appTitle(BuildContext context) {
    if (!trExists('app.name')) return 'Saudi Driving Theory Test';
    return tr('app.name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sharedPrefsProvider);
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    final baseLight = ModernTheme.lightTheme;
    final baseDark = ModernTheme.darkTheme;
    final lightTextTheme = AppFonts.textTheme(context, baseLight.textTheme);
    final darkTextTheme = AppFonts.textTheme(context, baseDark.textTheme);

    return MaterialApp.router(
      title: _appTitle(context),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: baseLight.copyWith(textTheme: lightTextTheme),
      darkTheme: baseDark.copyWith(textTheme: darkTextTheme),
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
