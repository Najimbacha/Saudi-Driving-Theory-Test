import 'dart:async';
import 'dart:math';

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../state/app_state.dart';

import '../../models/question.dart';

class ExamState {
  const ExamState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.flagged,
    required this.timeLeftSeconds,
    required this.originalDurationSeconds,
    required this.startedAt,
    required this.isCompleted,
    required this.strictMode,
  });

  final List<Question> questions;
  final int currentIndex;
  final Map<String, int> answers;
  final Set<String> flagged;
  final int timeLeftSeconds;
  final int originalDurationSeconds;
  final DateTime startedAt;
  final bool isCompleted;
  final bool strictMode;

  Question get currentQuestion => questions[currentIndex];

  ExamState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<String, int>? answers,
    Set<String>? flagged,
    int? timeLeftSeconds,
    int? originalDurationSeconds,
    DateTime? startedAt,
    bool? isCompleted,
    bool? strictMode,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      originalDurationSeconds: originalDurationSeconds ?? this.originalDurationSeconds,
      startedAt: startedAt ?? this.startedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      strictMode: strictMode ?? this.strictMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentIndex': currentIndex,
      'answers': answers,
      'flagged': flagged.toList(),
      'timeLeftSeconds': timeLeftSeconds,
      'originalDurationSeconds': originalDurationSeconds,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'strictMode': strictMode,
    };
  }

  factory ExamState.fromJson(Map<String, dynamic> json) {
    return ExamState(
      questions: (json['questions'] as List)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentIndex: json['currentIndex'] as int,
      answers: Map<String, int>.from(json['answers'] ?? {}),
      flagged: (json['flagged'] as List?)?.map((e) => e.toString()).toSet() ?? {},
      timeLeftSeconds: json['timeLeftSeconds'] as int,
      originalDurationSeconds: json['originalDurationSeconds'] as int? ?? 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int),
      isCompleted: json['isCompleted'] as bool,
      strictMode: json['strictMode'] as bool,
    );
  }
}

class ExamController extends StateNotifier<ExamState> {
  ExamController(this._prefs)
      : super(
          ExamState(
            questions: const [],
            currentIndex: 0,
            answers: const {},
            flagged: const {},
            timeLeftSeconds: 0,
            originalDurationSeconds: 0,
            startedAt: DateTime.fromMillisecondsSinceEpoch(0),
            isCompleted: false,
            strictMode: false,
          ),
        ) {
    _restoreSession();
  }

  final SharedPreferences _prefs;
  Timer? _timer;

  static const _storageKey = 'exam_session_v1';

  Future<void> _restoreSession() async {
    final jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return;

    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restoredState = ExamState.fromJson(jsonMap);

      if (restoredState.isCompleted) {
        // If completed, just load it but don't resume timer
        state = restoredState;
        return;
      }

      // Calculate elapsed time implementation
      if (restoredState.questions.isNotEmpty) {
        final now = DateTime.now();
        final elapsedSeconds = now.difference(restoredState.startedAt).inSeconds;
        final remaining = restoredState.originalDurationSeconds - elapsedSeconds;

        if (remaining <= 0) {
          // Time expired while offline
          state = restoredState.copyWith(timeLeftSeconds: 0, isCompleted: true);
        } else {
          // Resume with corrected time
          state = restoredState.copyWith(timeLeftSeconds: remaining);
          _startTimer();
        }
      }
    } catch (e) {
      // Corrupt state cleanup
      _prefs.remove(_storageKey);
    }
  }

  Future<void> _saveState() async {
    if (state.questions.isEmpty) {
      _prefs.remove(_storageKey);
      return;
    }
    await _prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }



  void start(List<Question> questions, {required int minutes, required bool strictMode}) {
    _timer?.cancel();
    state = ExamState(
      questions: _shuffle(questions),
      currentIndex: 0,
      answers: const {},
      flagged: const {},
      timeLeftSeconds: minutes * 60,
      originalDurationSeconds: minutes * 60,
      startedAt: DateTime.now(),
      isCompleted: false,
      strictMode: strictMode,
    );
    _saveState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isCompleted) {
        timer.cancel();
        return;
      }
      
      // Robust timer: Calculate remaining based on wall-clock time
      // This handles backgrounding/app-kill gracefully
      final now = DateTime.now();
      final elapsed = now.difference(state.startedAt).inSeconds;
      final remaining = state.originalDurationSeconds - elapsed;

      if (remaining <= 0) {
        state = state.copyWith(timeLeftSeconds: 0, isCompleted: true);
        _saveState();
        timer.cancel();
      } else {
        // Only update state if second changed (optimization)
        if (state.timeLeftSeconds != remaining) {
          state = state.copyWith(timeLeftSeconds: remaining);
          // Don't save every second - performance
        }
      }
    });
  }

  void selectAnswer(int index) {
    final question = state.currentQuestion;
    if (state.strictMode && state.answers.containsKey(question.id)) {
      return;
    }
    final next = Map<String, int>.from(state.answers);
    next[question.id] = index;
    state = state.copyWith(answers: next);
    _saveState();
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
    _saveState();
  }

  void goTo(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(currentIndex: index);
    _saveState();
  }

  void next() => goTo(state.currentIndex + 1);
  void previous() => goTo(state.currentIndex - 1);

  void finish() {
    _timer?.cancel();
    state = state.copyWith(isCompleted: true);
    _saveState();
  }

  /// Reset exam AND clear persisted session
  void reset() {
    _timer?.cancel();
    _prefs.remove(_storageKey);
    state = ExamState(
      questions: const [],
      currentIndex: 0,
      answers: const {},
      flagged: const {},
      timeLeftSeconds: 0,
      originalDurationSeconds: 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isCompleted: false,
      strictMode: false,
    );
  }

  static List<Question> _shuffle(List<Question> list) {
    final items = List<Question>.from(list);
    items.shuffle(Random());
    return items;
  }
}

final examProvider = StateNotifierProvider<ExamController, ExamState>((ref) {
  // Inject SharedPreferences
  final prefs = ref.watch(sharedPrefsProvider);
  final controller = ExamController(prefs);
  // Don't auto-reset on dispose to keep state while navigating
  // But DO stop timer on dispose? No, keep it running if implementation allows backgrounding
  // But StateNotifier disposes when UI is destroyed. 
  // With GoRouter and keepAlive/persistence, we might want to keep it.
  // Current app uses Shell, so provider stays alive.
  // We'll trust user to manually reset or start new exam.
  return controller;
});
