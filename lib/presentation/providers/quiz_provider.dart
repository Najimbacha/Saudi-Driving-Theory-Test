import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/question.dart';

class QuizState {
  const QuizState({
    required this.questions,
    required this.currentIndex,
    required this.selectedAnswers,
    required this.skippedQuestions,
    required this.showAnswer,
    required this.correctCount,
    required this.startedAt,
  });

  final List<Question> questions;
  final int currentIndex;
  final Map<String, int> selectedAnswers;
  final Set<String> skippedQuestions;
  final bool showAnswer;
  final int correctCount;
  final DateTime startedAt;

  bool get isCompleted => currentIndex >= questions.length;
  Question get currentQuestion => questions[currentIndex];

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<String, int>? selectedAnswers,
    Set<String>? skippedQuestions,
    bool? showAnswer,
    int? correctCount,
    DateTime? startedAt,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      showAnswer: showAnswer ?? this.showAnswer,
      correctCount: correctCount ?? this.correctCount,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  QuizController()
      : super(
          QuizState(
            questions: const [],
            currentIndex: 0,
            selectedAnswers: const {},
            skippedQuestions: const {},
            showAnswer: false,
            correctCount: 0,
            startedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );

  void start(List<Question> questions) {
    state = QuizState(
      questions: _shuffle(questions),
      currentIndex: 0,
      selectedAnswers: {},
      skippedQuestions: {},
      showAnswer: false,
      correctCount: 0,
      startedAt: DateTime.now(),
    );
  }

  void selectAnswer(int index) {
    if (state.showAnswer) return;
    final question = state.currentQuestion;
    final nextAnswers = Map<String, int>.from(state.selectedAnswers);
    final previous = nextAnswers[question.id];
    final wasCorrect = previous != null && previous == question.correctIndex;
    nextAnswers[question.id] = index;
    final nextSkipped = Set<String>.from(state.skippedQuestions)
      ..remove(question.id);
    final isCorrect = question.correctIndex == index;
    state = state.copyWith(
      selectedAnswers: nextAnswers,
      showAnswer: false,
      correctCount:
          state.correctCount - (wasCorrect ? 1 : 0) + (isCorrect ? 1 : 0),
      skippedQuestions: nextSkipped,
    );
  }

  void revealAnswer() {
    final question = state.currentQuestion;
    if (!state.selectedAnswers.containsKey(question.id)) return;
    if (state.showAnswer) return;
    state = state.copyWith(showAnswer: true);
  }

  void skipCurrent() {
    final question = state.currentQuestion;
    final nextAnswers = Map<String, int>.from(state.selectedAnswers);
    final previous = nextAnswers.remove(question.id);
    final nextSkipped = Set<String>.from(state.skippedQuestions)
      ..add(question.id);
    final wasCorrect = previous != null && previous == question.correctIndex;
    state = state.copyWith(
      selectedAnswers: nextAnswers,
      showAnswer: false,
      correctCount: state.correctCount - (wasCorrect ? 1 : 0),
      skippedQuestions: nextSkipped,
    );
  }

  void next() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(currentIndex: nextIndex);
      return;
    }
    state = state.copyWith(currentIndex: nextIndex, showAnswer: false);
  }

  void reset() {
    state = QuizState(
      questions: const [],
      currentIndex: 0,
      selectedAnswers: const {},
      skippedQuestions: const {},
      showAnswer: false,
      correctCount: 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<Question> _shuffle(List<Question> list) {
    final items = List<Question>.from(list);
    items.shuffle(Random());
    return items;
  }
}

final quizProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  return QuizController();
});
