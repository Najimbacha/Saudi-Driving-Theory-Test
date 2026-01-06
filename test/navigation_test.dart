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

import 'package:saudi_driving_theory_flutter/data/data_repository.dart';
import 'package:saudi_driving_theory_flutter/data/models/exam_result_model.dart';
import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/models/sign.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/exam/exam_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/quiz/practice_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/results/results_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/results/review_screen.dart';
import 'package:saudi_driving_theory_flutter/screens/stats_screen.dart';
import 'package:saudi_driving_theory_flutter/state/app_state.dart';
import 'package:saudi_driving_theory_flutter/state/data_state.dart';
import 'package:saudi_driving_theory_flutter/widgets/home_shell.dart';

class _FakeDataRepository extends DataRepository {
  @override
  Future<List<Question>> loadQuestions() async => const [];

  @override
  Future<List<AppSign>> loadSigns() async => const [];
}

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader(this._data);

  final Map<String, dynamic> _data;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async => _data;
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, _) => const HomeShell()),
      GoRoute(
        path: '/practice',
        builder: (context, _) => const HomeShell(initialIndex: 2),
      ),
      GoRoute(
        path: '/exam',
        builder: (context, _) => const HomeShell(initialIndex: 3),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) =>
            ResultsScreen(result: state.extra as ExamResult),
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) =>
            ReviewScreen(result: state.extra as ExamResult),
      ),
      GoRoute(path: '/stats', builder: (context, _) => const StatsScreen()),
    ],
  );
}

Widget _wrapWithApp({
  required GoRouter router,
  required SharedPreferences prefs,
  required AssetLoader assetLoader,
}) {
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      dataRepositoryProvider.overrideWithValue(_FakeDataRepository()),
    ],
    child: EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'unused',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      saveLocale: false,
      assetLoader: assetLoader,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  late Map<String, dynamic> translations;
  late AssetLoader assetLoader;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    final raw = await rootBundle.loadString('assets/i18n/en.json');
    translations = json.decode(raw) as Map<String, dynamic>;
    final translationData = Translations(translations);
    Localization.load(
      const Locale('en'),
      translations: translationData,
      fallbackTranslations: translationData,
    );
    assetLoader = _TestAssetLoader(translations);
  });

  group('Navigation Tests', () {
    testWidgets('Home → Practice navigation works',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = _buildRouter();

      await tester.pumpWidget(
        _wrapWithApp(
          router: router,
          prefs: prefs,
          assetLoader: assetLoader,
        ),
      );

      router.go('/practice');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PracticeFlowScreen), findsOneWidget);
    });

    testWidgets('Home → Exam navigation works', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = _buildRouter();

      await tester.pumpWidget(
        _wrapWithApp(
          router: router,
          prefs: prefs,
          assetLoader: assetLoader,
        ),
      );

      router.go('/exam');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ExamFlowScreen), findsOneWidget);
    });

    testWidgets('Exam completion → Result screen appears',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = _buildRouter();

      final result = ExamResult(
        id: 'test-1',
        dateTime: DateTime(2024, 1, 1),
        examType: 'exam',
        totalQuestions: 10,
        correctAnswers: 7,
        wrongAnswers: 3,
        skippedAnswers: 0,
        scorePercentage: 70.0,
        passed: true,
        timeTakenSeconds: 300,
        categoryScores: const {},
        questionAnswers: const [],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          router: router,
          prefs: prefs,
          assetLoader: assetLoader,
        ),
      );

      router.go('/results', extra: result);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ResultsScreen), findsOneWidget);
    });

    testWidgets('Review screen renders', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = _buildRouter();

      final result = ExamResult(
        id: 'test-2',
        dateTime: DateTime(2024, 1, 2),
        examType: 'exam',
        totalQuestions: 2,
        correctAnswers: 1,
        wrongAnswers: 1,
        skippedAnswers: 0,
        scorePercentage: 50.0,
        passed: false,
        timeTakenSeconds: 120,
        categoryScores: const {},
        questionAnswers: const [
          QuestionAnswer(
            questionId: 'q1',
            userAnswerIndex: 0,
            correctAnswerIndex: 0,
          ),
          QuestionAnswer(
            questionId: 'q2',
            userAnswerIndex: 1,
            correctAnswerIndex: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          router: router,
          prefs: prefs,
          assetLoader: assetLoader,
        ),
      );

      router.go('/review', extra: result);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ReviewScreen), findsOneWidget);
    });

    testWidgets('Normal screen back button pops', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = _buildRouter();

      await tester.pumpWidget(
        _wrapWithApp(
          router: router,
          prefs: prefs,
          assetLoader: assetLoader,
        ),
      );

      router.push('/stats');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        isNot('/stats'),
      );
    });
  });
}
