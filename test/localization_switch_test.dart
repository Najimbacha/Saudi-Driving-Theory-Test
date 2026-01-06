import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    switch (locale.languageCode) {
      case 'ar':
        return {
          'app': {'name': 'Arabic App'}
        };
      case 'ur':
        return {
          'app': {'name': 'Urdu App'}
        };
      case 'hi':
        return {
          'app': {'name': 'Hindi App'}
        };
      case 'bn':
        return {
          'app': {'name': 'Bangla App'}
        };
      default:
        return {
          'app': {'name': 'English App'}
        };
    }
  }
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('language switching updates localized text', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
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
        assetLoader: _TestLoader(),
        saveLocale: false,
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(
              body: Builder(
                builder: (innerContext) => Text(innerContext.tr('app.name')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('English App'), findsOneWidget);

    final context = tester.element(find.byType(Scaffold));
    await tester.runAsync(() async {
      await EasyLocalization.of(context)!.setLocale(const Locale('ar'));
    });
    await tester.pumpAndSettle();

    expect(find.text('Arabic App'), findsOneWidget);
  });
}
