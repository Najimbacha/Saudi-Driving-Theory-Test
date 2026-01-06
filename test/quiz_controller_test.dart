import 'package:flutter_test/flutter_test.dart';

import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/presentation/providers/quiz_provider.dart';

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
  test('selectAnswer updates selection and allows changes', () {
    final controller = QuizController();
    controller.start([_question('1', 0)]);

    controller.selectAnswer(1);
    expect(controller.state.selectedAnswers['1'], 1);
    expect(controller.state.showAnswer, false);
    expect(controller.state.correctCount, 0);

    controller.selectAnswer(0);
    expect(controller.state.selectedAnswers['1'], 0);
    expect(controller.state.correctCount, 1);
  });

  test('skipCurrent clears selection and marks skipped', () {
    final controller = QuizController();
    controller.start([_question('1', 0)]);

    controller.selectAnswer(0);
    expect(controller.state.correctCount, 1);

    controller.skipCurrent();
    expect(controller.state.selectedAnswers.containsKey('1'), false);
    expect(controller.state.skippedQuestions.contains('1'), true);
    expect(controller.state.correctCount, 0);
    expect(controller.state.showAnswer, false);
  });

  test('revealAnswer marks current question as checked', () {
    final controller = QuizController();
    controller.start([_question('1', 0)]);

    controller.selectAnswer(0);
    expect(controller.state.showAnswer, false);

    controller.revealAnswer();
    expect(controller.state.showAnswer, true);
  });

  test('next advances index and resets showAnswer', () {
    final controller = QuizController();
    controller.start([_question('1', 0), _question('2', 1)]);

    controller.selectAnswer(0);
    controller.revealAnswer();
    controller.next();

    expect(controller.state.currentIndex, 1);
    expect(controller.state.showAnswer, false);
  });
}
