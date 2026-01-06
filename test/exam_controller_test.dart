import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/presentation/providers/exam_provider.dart';

Question _question(String id, int correctIndex) {
  return Question(
    id: id,
    categoryId: 'rules',
    categoryKey: 'quiz.categories.rules',
    difficultyKey: 'quiz.difficulty.easy',
    questionKey: 'q.$id',
    optionsKeys: const ['a', 'b', 'c', 'd'],
    correctIndex: correctIndex,
    explanationKey: 'exp.$id',
    signId: null,
    questionText: 'Question $id',
    options: const ['A', 'B', 'C', 'D'],
    explanation: 'Explanation $id',
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('selectAnswer updates and allows changing answer', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ExamController(prefs);
    controller.start([_question('1', 0)], minutes: 1, strictMode: true);

    controller.selectAnswer(1);
    expect(controller.state.answers['1'], 1);

    controller.selectAnswer(0);
    expect(controller.state.answers['1'], 0);
    expect(controller.state.skipped.contains('1'), false);
  });

  test('skipCurrent clears answer and marks skipped', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ExamController(prefs);
    controller.start([_question('1', 0)], minutes: 1, strictMode: false);

    controller.selectAnswer(0);
    controller.skipCurrent();

    expect(controller.state.answers.containsKey('1'), false);
    expect(controller.state.skipped.contains('1'), true);
  });

  test('finish marks exam completed', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ExamController(prefs);
    controller.start([_question('1', 0)], minutes: 1, strictMode: false);

    controller.finish();
    expect(controller.state.isCompleted, true);
  });
}
