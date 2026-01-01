import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/question.dart';

class ExamState {
  const ExamState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.flagged,
    required this.timeLeftSeconds,
    required this.startedAt,
    required this.isCompleted,
  });

  final List<Question> questions;
  final int currentIndex;
  final Map<String, int> answers;
  final Set<String> flagged;
  final int timeLeftSeconds;
  final DateTime startedAt;
  final bool isCompleted;

  Question get currentQuestion => questions[currentIndex];

  ExamState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<String, int>? answers,
    Set<String>? flagged,
    int? timeLeftSeconds,
    DateTime? startedAt,
    bool? isCompleted,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      startedAt: startedAt ?? this.startedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ExamController extends StateNotifier<ExamState> {
  ExamController()
      : super(
          ExamState(
            questions: const [],
            currentIndex: 0,
            answers: const {},
            flagged: const {},
            timeLeftSeconds: 0,
            startedAt: DateTime.fromMillisecondsSinceEpoch(0),
            isCompleted: false,
          ),
        );

  Timer? _timer;

  void start(List<Question> questions, {required int minutes}) {
    _timer?.cancel();
    state = ExamState(
      questions: _shuffle(questions),
      currentIndex: 0,
      answers: const {},
      flagged: const {},
      timeLeftSeconds: minutes * 60,
      startedAt: DateTime.now(),
      isCompleted: false,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isCompleted) {
        timer.cancel();
        return;
      }
      final next = state.timeLeftSeconds - 1;
      if (next <= 0) {
        state = state.copyWith(timeLeftSeconds: 0, isCompleted: true);
        timer.cancel();
      } else {
        state = state.copyWith(timeLeftSeconds: next);
      }
    });
  }

  void selectAnswer(int index) {
    final question = state.currentQuestion;
    final next = Map<String, int>.from(state.answers);
    next[question.id] = index;
    state = state.copyWith(answers: next);
  }

  void toggleFlag() {
    final question = state.currentQuestion;
    final next = Set<String>.from(state.flagged);
    if (next.contains(question.id)) {
      next.remove(question.id);
    } else {
      next.add(question.id);
    }
    state = state.copyWith(flagged: next);
  }

  void goTo(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(currentIndex: index);
  }

  void next() => goTo(state.currentIndex + 1);
  void previous() => goTo(state.currentIndex - 1);

  void finish() {
    _timer?.cancel();
    state = state.copyWith(isCompleted: true);
  }

  void reset() {
    _timer?.cancel();
    state = ExamState(
      questions: const [],
      currentIndex: 0,
      answers: const {},
      flagged: const {},
      timeLeftSeconds: 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isCompleted: false,
    );
  }

  static List<Question> _shuffle(List<Question> list) {
    final items = List<Question>.from(list);
    items.shuffle(Random());
    return items;
  }
}

final examProvider = StateNotifierProvider<ExamController, ExamState>((ref) {
  final controller = ExamController();
  ref.onDispose(controller.reset);
  return controller;
});
