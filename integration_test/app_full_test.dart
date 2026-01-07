import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saudi_driving_theory_flutter/data/models/exam_result_model.dart';
import 'package:saudi_driving_theory_flutter/main.dart' as app;

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for: $finder');
}

Future<void> pumpUntilAnyFound(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
  }
  throw TestFailure('Timed out waiting for any of: $finders');
}

Future<void> tapAndPump(
  WidgetTester tester,
  Finder finder, {
  Duration wait = const Duration(milliseconds: 400),
}) async {
  final target = finder.evaluate().length > 1 ? finder.first : finder;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump(wait);
}

Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder scrollable,
  Finder target,
) async {
  for (var i = 0; i < 10; i += 1) {
    if (target.evaluate().isNotEmpty) return;
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> scrollToTop(WidgetTester tester, Finder scrollable) async {
  for (var i = 0; i < 6; i += 1) {
    await tester.drag(scrollable, const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump(const Duration(milliseconds: 600));
}

ExamResult _dummyResult() {
  return ExamResult(
    id: 'test-result',
    dateTime: DateTime.now(),
    examType: 'exam',
    totalQuestions: 10,
    correctAnswers: 7,
    wrongAnswers: 2,
    skippedAnswers: 1,
    scorePercentage: 70,
    passed: true,
    timeTakenSeconds: 120,
    categoryScores: const {'rules': 3, 'signs': 4},
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

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  if (binding is IntegrationTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  testWidgets(
    'full app smoke test',
    (tester) async {
      tester.binding.platformDispatcher.localeTestValue = const Locale('en');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setBool('examFreeUsed', false);
      await prefs.setInt('examRewardTokenCount', 0);

      app.main();
      await tester.pump(const Duration(milliseconds: 200));

      await pumpUntilAnyFound(
        tester,
        [find.text('Get Started'), find.text('Next'), find.text('Quick Start')],
        timeout: const Duration(seconds: 20),
      );

      if (find.text('Get Started').evaluate().isNotEmpty ||
          find.text('Next').evaluate().isNotEmpty) {
        for (var i = 0; i < 3; i += 1) {
          if (find.text('Next').evaluate().isNotEmpty) {
            await tapAndPump(tester, find.text('Next'));
          } else if (find.text('Get Started').evaluate().isNotEmpty) {
            await tapAndPump(tester, find.text('Get Started'));
            break;
          }
        }
      }

      await pumpUntilFound(tester, find.text('Quick Start'));

      await tapAndPump(tester, find.text('Practice Questions'));
      await pumpUntilFound(tester, find.text('Start Quiz'));
      await tapAndPump(tester, find.text('Start Quiz'));
      await pumpUntilFound(tester, find.text('Skip'));
      await tapAndPump(tester, find.text('A').first);
      await tapAndPump(tester, find.text('Next'));
      await tapAndPump(tester, find.text('Next'));
      await systemBack(tester);
      await scrollToTop(tester, find.byType(CustomScrollView));
      await pumpUntilFound(tester, find.text('Quick Start'));

      await tapAndPump(tester, find.text('Full Practice Exam'));
      await pumpUntilFound(tester, find.text('Select Exam Mode'));
      await tapAndPump(tester, find.text('Quick'));
      await pumpUntilFound(tester, find.text('Start Practice'));
      await tapAndPump(tester, find.text('Start Practice'));
      await pumpUntilFound(tester, find.text('Skip'));
      await tapAndPump(tester, find.text('A').first);
      await tapAndPump(tester, find.text('Next'));
      await systemBack(tester);
      await pumpUntilFound(tester, find.text('Exit'));
      await tapAndPump(tester, find.text('Exit'));
      await scrollToTop(tester, find.byType(CustomScrollView));
      await pumpUntilFound(tester, find.text('Quick Start'));

      await tapAndPump(tester, find.text('Signs'));
      await pumpUntilFound(tester, find.text('Search signs...'));
      await pumpUntilFound(tester, find.byType(SvgPicture));
      await tapAndPump(tester, find.byType(SvgPicture).first);
      await systemBack(tester);
      await tapAndPump(tester, find.text('Home'));
      await scrollToTop(tester, find.byType(CustomScrollView));
      await pumpUntilFound(tester, find.text('Quick Start'));

      final homeScroll = find.byType(CustomScrollView);
      await scrollUntilVisible(
        tester,
        homeScroll,
        find.text('Practice by Topic'),
      );
      await tapAndPump(tester, find.text('Practice by Topic'));
      await pumpUntilFound(tester, find.text('Practice Categories'));
      await systemBack(tester);

      await scrollUntilVisible(tester, homeScroll, find.text('My Progress'));
      await tapAndPump(tester, find.text('My Progress'));
      await pumpUntilFound(tester, find.text('Your Statistics'));
      await systemBack(tester);

      await scrollUntilVisible(tester, homeScroll, find.text('My Results'));
      await tapAndPump(tester, find.text('My Results'));
      await pumpUntilFound(tester, find.text('Exam History'));
      await systemBack(tester);

      await tapAndPump(tester, find.text('Settings'));
      await pumpUntilFound(tester, find.text('Settings'));
      await tapAndPump(tester, find.text('Language'));
      await pumpUntilFound(tester, find.text('English'));
      await tapAndPump(tester, find.widgetWithText(InkWell, 'English'));
      await tapAndPump(tester, find.text('Theme'));
      await pumpUntilFound(tester, find.text('System'));
      await tapAndPump(tester, find.widgetWithText(InkWell, 'System'));
      await systemBack(tester);
      await scrollToTop(tester, find.byType(CustomScrollView));
      await pumpUntilFound(tester, find.text('Quick Start'));

      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/favorites');
      await pumpUntilFound(tester, find.text('Favorites'));
      router.go('/flashcards');
      await pumpUntilFound(tester, find.text('Flashcards'));
      router.go('/learn');
      await pumpUntilFound(tester, find.text('Learn Driving Theory'));
      router.go('/achievements');
      await pumpUntilFound(tester, find.text('Achievements'));
      router.go('/credits');
      await pumpUntilFound(tester, find.text('Credits & Attribution'));
      router.go('/violation-points');
      await pumpUntilFound(tester, find.text('Traffic Violation Point System'));
      router.go('/traffic-fines');
      await pumpUntilFound(
          tester, find.text('Traffic Fines in Saudi Arabia (Educational Guide)'));
      router.go('/license-guide');
      await pumpUntilFound(
          tester, find.text('How to apply for Driving license'));
      router.go('/privacy');
      await pumpUntilFound(tester, find.text('Privacy Policy'));

      final result = _dummyResult();
      router.go('/results', extra: result);
      await pumpUntilFound(tester, find.text('Results'));
      await tapAndPump(tester, find.text('Review Answers'));
      await pumpUntilFound(tester, find.text('Answer Review'));

      router.go('/home');
      await pumpUntilFound(tester, find.text('Quick Start'));
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
