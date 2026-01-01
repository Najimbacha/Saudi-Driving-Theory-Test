import 'package:flutter_test/flutter_test.dart';
import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/presentation/providers/quiz_provider.dart';

void main() {
  test('QuizController tracks answers and progress', () {
    final controller = QuizController();
    final questions = [
      const Question(
        id: 'q1',
        categoryId: 'signs',
        categoryKey: 'quiz.categories.signs',
        difficultyKey: 'quiz.difficulty.easy',
        questionKey: 'quiz.q.q1.text',
        optionsKeys: ['quiz.q.q1.a', 'quiz.q.q1.b'],
        correctIndex: 0,
        explanationKey: null,
        signId: null,
      ),
      const Question(
        id: 'q2',
        categoryId: 'rules',
        categoryKey: 'quiz.categories.rules',
        difficultyKey: 'quiz.difficulty.easy',
        questionKey: 'quiz.q.q2.text',
        optionsKeys: ['quiz.q.q2.a', 'quiz.q.q2.b'],
        correctIndex: 1,
        explanationKey: null,
        signId: null,
      ),
    ];

    controller.start(questions);
    expect(controller.state.questions.length, 2);

    controller.selectAnswer(controller.state.currentQuestion.correctIndex);
    expect(controller.state.correctCount, 1);
    expect(controller.state.showAnswer, true);

    controller.next();
    expect(controller.state.currentIndex, 1);
  });
}
