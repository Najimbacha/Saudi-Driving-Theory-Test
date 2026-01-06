import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'last-test-session';

class PracticeSessionPayload {
  const PracticeSessionPayload({
    required this.mode,
    required this.questions,
    required this.current,
    required this.selected,
    required this.showAnswer,
    required this.score,
    required this.sessionWrongIds,
    required this.sessionResults,
    required this.selectedCategory,
  });

  final String mode;
  final List<String> questions;
  final int current;
  final int? selected;
  final bool showAnswer;
  final int score;
  final List<String> sessionWrongIds;
  final List<Map<String, dynamic>> sessionResults;
  final String? selectedCategory;

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'questions': questions,
        'current': current,
        'selected': selected,
        'showAnswer': showAnswer,
        'score': score,
        'sessionWrongIds': sessionWrongIds,
        'sessionResults': sessionResults,
        'selectedCategory': selectedCategory,
      };

  static PracticeSessionPayload fromJson(Map<String, dynamic> json) =>
      PracticeSessionPayload(
        mode: json['mode'] as String,
        questions: List<String>.from(json['questions'] ?? const []),
        current: json['current'] as int? ?? 0,
        selected: json['selected'] as int?,
        showAnswer: json['showAnswer'] as bool? ?? false,
        score: json['score'] as int? ?? 0,
        sessionWrongIds: List<String>.from(json['sessionWrongIds'] ?? const []),
        sessionResults:
            List<Map<String, dynamic>>.from(json['sessionResults'] ?? const []),
        selectedCategory: json['selectedCategory'] as String?,
      );
}

class ExamSessionPayload {
  const ExamSessionPayload({
    required this.selectedMode,
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.timeLeft,
    required this.timerEnabled,
  });

  final String selectedMode;
  final List<String> questions;
  final int currentIndex;
  final List<Map<String, dynamic>> answers;
  final int timeLeft;
  final bool timerEnabled;

  Map<String, dynamic> toJson() => {
        'selectedMode': selectedMode,
        'questions': questions,
        'currentIndex': currentIndex,
        'answers': answers,
        'timeLeft': timeLeft,
        'timerEnabled': timerEnabled,
      };

  static ExamSessionPayload fromJson(Map<String, dynamic> json) =>
      ExamSessionPayload(
        selectedMode: json['selectedMode'] as String,
        questions: List<String>.from(json['questions'] ?? const []),
        currentIndex: json['currentIndex'] as int? ?? 0,
        answers: List<Map<String, dynamic>>.from(json['answers'] ?? const []),
        timeLeft: json['timeLeft'] as int? ?? 0,
        timerEnabled: json['timerEnabled'] as bool? ?? true,
      );
}

class TestSession {
  const TestSession.practice(this.updatedAt, this.payload) : type = 'practice';
  const TestSession.exam(this.updatedAt, this.payload) : type = 'exam';

  final String type;
  final int updatedAt;
  final Object payload;

  Map<String, dynamic> toJson() => {
        'type': type,
        'updatedAt': updatedAt,
        'payload': payload is PracticeSessionPayload
            ? (payload as PracticeSessionPayload).toJson()
            : (payload as ExamSessionPayload).toJson(),
      };

  static TestSession? fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'practice') {
      return TestSession.practice(
        json['updatedAt'] as int? ?? 0,
        PracticeSessionPayload.fromJson(
            Map<String, dynamic>.from(json['payload'] as Map)),
      );
    }
    if (type == 'exam') {
      return TestSession.exam(
        json['updatedAt'] as int? ?? 0,
        ExamSessionPayload.fromJson(
            Map<String, dynamic>.from(json['payload'] as Map)),
      );
    }
    return null;
  }
}

TestSession? loadTestSession(SharedPreferences prefs) {
  final raw = prefs.getString(_storageKey);
  if (raw == null) return null;
  try {
    return TestSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
}

void saveTestSession(SharedPreferences prefs, TestSession session) {
  prefs.setString(_storageKey, jsonEncode(session.toJson()));
}

void clearTestSession(SharedPreferences prefs) {
  prefs.remove(_storageKey);
}
