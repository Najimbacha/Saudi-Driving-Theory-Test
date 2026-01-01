import 'package:flutter_test/flutter_test.dart';
import 'package:saudi_driving_theory_flutter/models/question.dart';
import 'package:saudi_driving_theory_flutter/presentation/providers/exam_provider.dart';

void main() {
  test('ExamController starts and records answers', () {
    final controller = ExamController();
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

    controller.start(questions, minutes: 1, strictMode: true);
    expect(controller.state.questions.length, 2);
    expect(controller.state.timeLeftSeconds, 60);

    final currentId = controller.state.currentQuestion.id;
    controller.selectAnswer(1);
    expect(controller.state.answers[currentId], 1);

    controller.toggleFlag();
    expect(controller.state.flagged.contains(currentId), true);

    controller.finish();
    expect(controller.state.isCompleted, true);

    controller.reset();
  });
}
