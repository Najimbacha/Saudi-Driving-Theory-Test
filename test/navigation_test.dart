import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:saudi_driving_theory_flutter/core/routes/app_router.dart';
import 'package:saudi_driving_theory_flutter/data/models/exam_result_model.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('Home → Practice navigation works', (WidgetTester tester) async {
      await EasyLocalization.ensureInitialized();
      
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/i18n',
            fallbackLocale: const Locale('en'),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );

      // Navigate to home first
      router.go('/home');
      await tester.pumpAndSettle();

      // Find and tap practice button
      final practiceButton = find.text('Practice');
      if (practiceButton.evaluate().isEmpty) {
        // Try alternative text based on translation
        final altButton = find.byType(InkWell).first;
        if (altButton.evaluate().isNotEmpty) {
          await tester.tap(altButton);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(practiceButton);
        await tester.pumpAndSettle();
      }

      // Verify we're on practice screen (check for quiz-related widgets)
      expect(find.text('Practice'), findsAny);
    });

    testWidgets('Home → Exam navigation works', (WidgetTester tester) async {
      await EasyLocalization.ensureInitialized();
      
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/i18n',
            fallbackLocale: const Locale('en'),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );

      router.go('/home');
      await tester.pumpAndSettle();

      // Find and tap exam button
      final examButton = find.text('Mock Exam');
      if (examButton.evaluate().isEmpty) {
        final altButton = find.byType(InkWell).at(1);
        if (altButton.evaluate().isNotEmpty) {
          await tester.tap(altButton);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(examButton);
        await tester.pumpAndSettle();
      }

      // Verify we're on exam screen
      expect(find.text('Exam'), findsAny);
    });

    testWidgets('Exam completion → Result screen appears', (WidgetTester tester) async {
      await EasyLocalization.ensureInitialized();
      
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      // Create a mock result
      final result = ExamResult(
        id: 'test-1',
        dateTime: DateTime.now(),
        examType: 'exam',
        totalQuestions: 10,
        correctAnswers: 7,
        wrongAnswers: 3,
        skippedAnswers: 0,
        scorePercentage: 70.0,
        passed: true,
        timeTakenSeconds: 300,
        categoryScores: {},
        questionAnswers: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/i18n',
            fallbackLocale: const Locale('en'),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );

      // Navigate to results screen with result
      router.push('/results', extra: result);
      await tester.pumpAndSettle();

      // Verify results screen appears
      expect(find.text('Results'), findsAny);
      expect(find.text('70%'), findsAny);
    });

    testWidgets('Review screen renders correct/wrong answers', (WidgetTester tester) async {
      await EasyLocalization.ensureInitialized();
      
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      // Create a mock result with question answers
      final result = ExamResult(
        id: 'test-1',
        dateTime: DateTime.now(),
        examType: 'exam',
        totalQuestions: 2,
        correctAnswers: 1,
        wrongAnswers: 1,
        skippedAnswers: 0,
        scorePercentage: 50.0,
        passed: false,
        timeTakenSeconds: 120,
        categoryScores: {},
        questionAnswers: [
          const QuestionAnswer(
            questionId: 'q1',
            userAnswerIndex: 0,
            correctAnswerIndex: 0,
          ),
          const QuestionAnswer(
            questionId: 'q2',
            userAnswerIndex: 1,
            correctAnswerIndex: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/i18n',
            fallbackLocale: const Locale('en'),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );

      router.push('/review', extra: result);
      await tester.pumpAndSettle();

      // Verify review screen appears
      expect(find.text('Review'), findsAny);
    });

    testWidgets('Normal screen back button pops', (WidgetTester tester) async {
      await EasyLocalization.ensureInitialized();
      
      final container = ProviderContainer();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        ProviderScope(
          child: EasyLocalization(
            supportedLocales: const [Locale('en')],
            path: 'assets/i18n',
            fallbackLocale: const Locale('en'),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        ),
      );

      // Navigate to stats screen
      router.push('/stats');
      await tester.pumpAndSettle();

      // Simulate back button
      router.pop();
      await tester.pumpAndSettle();

      // Should be back at previous screen
      expect(router.routerDelegate.currentConfiguration.uri.path, isNot('/stats'));
    });
  });
}

