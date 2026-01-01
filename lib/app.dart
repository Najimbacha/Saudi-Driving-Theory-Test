import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/routes/app_router.dart';
import 'state/app_state.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sharedPrefsProvider);
    final router = ref.watch(appRouterProvider);

    final settings = ref.watch(appSettingsProvider);
    ref.listen<AppSettingsState>(appSettingsProvider, (previous, next) {
      if (next.languageCode != context.locale.languageCode) {
        context.setLocale(Locale(next.languageCode));
      }
    });
    return MaterialApp.router(
      title: 'Saudi Driving Theory Test',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
