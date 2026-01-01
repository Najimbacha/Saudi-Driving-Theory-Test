import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saudi_driving_theory_flutter/data/data_repository.dart';
import 'package:saudi_driving_theory_flutter/data/models/exam_result_model.dart';
import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/models/sign.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/categories/categories_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/exam/exam_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/home/home_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/quiz/practice_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/results/results_screen.dart';
import 'package:saudi_driving_theory_flutter/presentation/screens/results/review_screen.dart';
import 'package:saudi_driving_theory_flutter/screens/signs_screen.dart';
import 'package:saudi_driving_theory_flutter/screens/stats_screen.dart';
import 'package:saudi_driving_theory_flutter/state/app_state.dart';
import 'package:saudi_driving_theory_flutter/state/data_state.dart';

class _FakeDataRepository extends DataRepository {
  _FakeDataRepository(this._questions);

  final List<Question> _questions;

  @override
  Future<List<Question>> loadQuestions() async => _questions;

  @override
  Future<List<AppSign>> loadSigns() async => const [];
}

List<Question> _fakeQuestions() {
  return const [
    Question(
      id: 'q1',
      categoryId: 'traffic_signs',
      categoryKey: 'quiz.categories.trafficSigns',
      difficultyKey: 'quiz.difficulty.easy',
      questionKey: 'questions.q1',
      optionsKeys: ['options.a', 'options.b', 'options.c', 'options.d'],
      correctIndex: 0,
      explanationKey: 'explanations.q1',
      signId: null,
      questionText: 'What does this sign mean?',
      questionTextAr: 'ماذا تعني هذه الإشارة؟',
      options: ['Stop', 'Yield', 'No entry', 'Speed limit'],
      optionsAr: ['قف', 'أفسح الطريق', 'ممنوع الدخول', 'حد السرعة'],
      explanation: 'It means stop.',
      explanationAr: 'تعني قف.',
    ),
    Question(
      id: 'q2',
      categoryId: 'traffic_rules',
      categoryKey: 'quiz.categories.trafficRules',
      difficultyKey: 'quiz.difficulty.easy',
      questionKey: 'questions.q2',
      optionsKeys: ['options.a', 'options.b', 'options.c', 'options.d'],
      correctIndex: 2,
      explanationKey: 'explanations.q2',
      signId: null,
      questionText: 'When can you overtake?',
      questionTextAr: 'متى يمكنك التجاوز؟',
      options: ['Never', 'Always', 'When it is safe', 'At night'],
      optionsAr: ['أبدًا', 'دائمًا', 'عندما يكون آمنًا', 'في الليل'],
      explanation: 'Only when it is safe.',
      explanationAr: 'فقط عندما يكون آمنًا.',
    ),
  ];
}

ExamResult _fakeResult() {
  return ExamResult(
    id: 'r1',
    dateTime: DateTime(2024, 1, 1),
    examType: 'exam',
    totalQuestions: 2,
    correctAnswers: 1,
    wrongAnswers: 1,
    skippedAnswers: 0,
    scorePercentage: 50,
    passed: false,
    timeTakenSeconds: 90,
    categoryScores: const {'traffic_signs': 1, 'traffic_rules': 0},
    questionAnswers: const [
      QuestionAnswer(
        questionId: 'q1',
        userAnswerIndex: 0,
        correctAnswerIndex: 0,
      ),
      QuestionAnswer(
        questionId: 'q2',
        userAnswerIndex: 1,
        correctAnswerIndex: 2,
      ),
    ],
  );
}

Widget _wrapWithApp({
  required Widget child,
  required SharedPreferences prefs,
}) {
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      dataRepositoryProvider.overrideWithValue(_FakeDataRepository(_fakeQuestions())),
    ],
    child: EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ur'),
        Locale('hi'),
        Locale('bn'),
      ],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            locale: const Locale('en'),
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: child,
          );
        },
      ),
    ),
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Widget child,
  required SharedPreferences prefs,
  required Size size,
  required double textScale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(_wrapWithApp(child: child, prefs: prefs));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('Layout smoke test on small and large screens', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final screens = <Widget Function()>[
      () => const HomeDashboardScreen(),
      () => const CategoriesScreen(),
      () => const PracticeFlowScreen(),
      () => const ExamFlowScreen(),
      () => ResultsScreen(result: _fakeResult()),
      () => ReviewScreen(result: _fakeResult()),
      () => const SignsScreen(),
      () => const StatsScreen(),
    ];

    const sizes = <Size>[
      Size(320, 568),
      Size(360, 800),
      Size(414, 896),
    ];
    const scales = <double>[1.0, 1.3];

    for (final size in sizes) {
      for (final scale in scales) {
        for (final buildScreen in screens) {
          final screen = buildScreen();
          await _pumpScreen(
            tester,
            child: screen,
            prefs: prefs,
            size: size,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
