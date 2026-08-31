import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saudi_driving_theory_flutter/core/theme/modern_theme.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/home/home_screen.dart';
import 'package:saudi_driving_theory_flutter/state/app_state.dart';
import 'package:saudi_driving_theory_flutter/widgets/glass_container.dart';

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader(this._data);

  final Map<String, dynamic> _data;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async => _data;
}

Widget _wrapWithMaterialApp({
  required Widget child,
  required SharedPreferences prefs,
  required ThemeMode themeMode,
  required AssetLoader assetLoader,
}) {
  return ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('hi'),
        Locale('bn'),
      ],
      path: 'unused',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: assetLoader,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            theme: ModernTheme.lightTheme,
            darkTheme: ModernTheme.darkTheme,
            themeMode: themeMode,
            home: child,
          );
        },
      ),
    ),
  );
}

Widget _wrapWithRouterApp({
  required GoRouter router,
  required SharedPreferences prefs,
  required AssetLoader assetLoader,
}) {
  return ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('hi'),
        Locale('bn'),
      ],
      path: 'unused',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: assetLoader,
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            routerConfig: router,
          );
        },
      ),
    ),
  );
}

GoRouter _buildHomeRouter() {
  Widget placeholder(String label) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }

  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (_, __) => const HomeDashboardScreen()),
      GoRoute(path: '/practice', builder: (_, __) => placeholder('practice')),
      GoRoute(path: '/exam', builder: (_, __) => placeholder('exam')),
      GoRoute(path: '/signs', builder: (_, __) => placeholder('signs')),
      GoRoute(path: '/stats', builder: (_, __) => placeholder('stats')),
      GoRoute(path: '/history', builder: (_, __) => placeholder('history')),
      GoRoute(path: '/settings', builder: (_, __) => placeholder('settings')),
      GoRoute(
        path: '/categories',
        builder: (_, __) => placeholder('categories'),
      ),
    ],
  );
}

Future<void> _scrollHomeToTop(WidgetTester tester) async {
  final scrollable = find.byType(CustomScrollView);
  for (var i = 0; i < 6; i += 1) {
    await tester.drag(scrollable, const Offset(0, 300));
    await tester.pumpAndSettle();
  }
}

Future<void> _tapAndExpectPath(
  WidgetTester tester,
  GoRouter router,
  Finder finder,
  String expectedScreenLabel,
) async {
  expect(finder, findsWidgets);
  final target = finder.first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();

  expect(find.text(expectedScreenLabel), findsOneWidget);

  router.go('/home');
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetLoader assetLoader;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    final raw = await rootBundle.loadString('assets/i18n/en.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final translationData = Translations(map);
    Localization.load(
      const Locale('en'),
      translations: translationData,
      fallbackTranslations: translationData,
    );
    assetLoader = _TestAssetLoader(map);
  });

  testWidgets('home keeps learning paths above quick start in both themes', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          child: const HomeDashboardScreen(),
          prefs: prefs,
          themeMode: mode,
          assetLoader: assetLoader,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final learningSection = find.byKey(
        const Key('home_section_learning_paths'),
        skipOffstage: false,
      );
      final quickStartSection = find.byKey(
        const Key('home_section_quick_start'),
        skipOffstage: false,
      );

      expect(learningSection, findsOneWidget);
      expect(quickStartSection, findsOneWidget);

      final learningTop = tester.getTopLeft(learningSection).dy;
      final quickTop = tester.getTopLeft(quickStartSection).dy;
      expect(learningTop, lessThan(quickTop));
    }
  });

  testWidgets('home actions navigate to expected routes', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final router = _buildHomeRouter();

    await tester.pumpWidget(
      _wrapWithRouterApp(
        router: router,
        prefs: prefs,
        assetLoader: assetLoader,
      ),
    );
    await tester.pumpAndSettle();

    await _tapAndExpectPath(
      tester,
      router,
      find.text('Practice by Topic'),
      'categories',
    );
    await _tapAndExpectPath(
      tester,
      router,
      find.text('Traffic Signs'),
      'signs',
    );
    await _tapAndExpectPath(
      tester,
      router,
      find.text('My Progress'),
      'stats',
    );
    await _tapAndExpectPath(
      tester,
      router,
      find.text('My Results'),
      'history',
    );
    await _tapAndExpectPath(
      tester,
      router,
      find.text('Practice Questions'),
      'practice',
    );
    await _tapAndExpectPath(
      tester,
      router,
      find.text('Full Practice Exam'),
      'exam',
    );

    router.go('/home');
    await tester.pumpAndSettle();
    await _scrollHomeToTop(tester);
    expect(
        find.byKey(const Key('home_section_learning_paths')), findsOneWidget);

    final settingsFinder = find.byKey(const Key('home_action_settings'));
    expect(settingsFinder, findsOneWidget);
    await tester.tap(settingsFinder);
    await tester.pumpAndSettle();
    expect(find.text('settings'), findsOneWidget);
  });

  testWidgets('glass container skips BackdropFilter when blur is zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            blur: 0,
            child: SizedBox(width: 20, height: 20),
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('glass container uses BackdropFilter when blur is positive', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassContainer(
            blur: 6,
            child: SizedBox(width: 20, height: 20),
          ),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
