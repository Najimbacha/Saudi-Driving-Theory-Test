import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';

class MistakeRecord {
  MistakeRecord({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.timestamp,
    required this.category,
    required this.difficulty,
    required this.correctStreak,
  });

  final String questionId;
  final int selectedAnswer;
  final int correctAnswer;
  final int timestamp;
  final String category;
  final String difficulty;
  final int correctStreak;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
        'correctAnswer': correctAnswer,
        'timestamp': timestamp,
        'category': category,
        'difficulty': difficulty,
        'correctStreak': correctStreak,
      };

  static MistakeRecord fromJson(Map<String, dynamic> json) => MistakeRecord(
        questionId: json['questionId'] as String,
        selectedAnswer: json['selectedAnswer'] as int,
        correctAnswer: json['correctAnswer'] as int,
        timestamp: json['timestamp'] as int,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        correctStreak: json['correctStreak'] as int? ?? 0,
      );
}

class CategoryStat {
  CategoryStat({required this.correct, required this.total, required this.accuracy});

  final int correct;
  final int total;
  final int accuracy;

  Map<String, dynamic> toJson() => {
        'correct': correct,
        'total': total,
        'accuracy': accuracy,
      };

  static CategoryStat fromJson(Map<String, dynamic> json) => CategoryStat(
        correct: json['correct'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
        accuracy: json['accuracy'] as int? ?? 0,
      );
}

class ReviewItem {
  ReviewItem({
    required this.questionId,
    required this.interval,
    required this.easeFactor,
    required this.nextReviewDate,
    required this.repetitions,
  });

  final String questionId;
  final double interval;
  final double easeFactor;
  final int nextReviewDate;
  final int repetitions;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'interval': interval,
        'easeFactor': easeFactor,
        'nextReviewDate': nextReviewDate,
        'repetitions': repetitions,
      };

  static ReviewItem fromJson(Map<String, dynamic> json) => ReviewItem(
        questionId: json['questionId'] as String,
        interval: (json['interval'] as num?)?.toDouble() ?? 0,
        easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
        nextReviewDate: json['nextReviewDate'] as int? ?? 0,
        repetitions: json['repetitions'] as int? ?? 0,
      );
}

class LearningState {
  LearningState({
    required this.mistakes,
    required this.categoryStats,
    required this.reviewQueue,
    required this.mastery,
    required this.streak,
    required this.totalAnswered,
    required this.totalCorrect,
  });

  final List<MistakeRecord> mistakes;
  final Map<String, CategoryStat> categoryStats;
  final List<ReviewItem> reviewQueue;
  final Map<String, String> mastery;
  final Map<String, dynamic> streak;
  final int totalAnswered;
  final int totalCorrect;

  Map<String, dynamic> toJson() => {
        'mistakes': mistakes.map((m) => m.toJson()).toList(),
        'categoryStats': categoryStats.map((k, v) => MapEntry(k, v.toJson())),
        'reviewQueue': reviewQueue.map((r) => r.toJson()).toList(),
        'mastery': mastery,
        'streak': streak,
        'totalAnswered': totalAnswered,
        'totalCorrect': totalCorrect,
      };

  static LearningState fromJson(Map<String, dynamic> json) => LearningState(
        mistakes: (json['mistakes'] as List? ?? const [])
            .map((m) => MistakeRecord.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList(),
        categoryStats: (json['categoryStats'] as Map? ?? const {})
            .map((key, value) => MapEntry(
                  key as String,
                  CategoryStat.fromJson(Map<String, dynamic>.from(value as Map)),
                )),
        reviewQueue: (json['reviewQueue'] as List? ?? const [])
            .map((r) => ReviewItem.fromJson(Map<String, dynamic>.from(r as Map)))
            .toList(),
        mastery: Map<String, String>.from(json['mastery'] ?? const {}),
        streak: Map<String, dynamic>.from(json['streak'] ?? const {'current': 0, 'lastDate': '', 'longest': 0}),
        totalAnswered: json['totalAnswered'] as int? ?? 0,
        totalCorrect: json['totalCorrect'] as int? ?? 0,
      );
}

const _storageKey = 'driving-app-learning-state';
const _masteryStreakThreshold = 3;

class LearningNotifier extends StateNotifier<LearningState> {
  LearningNotifier(this._prefs)
      : super(
          LearningState.fromJson(
            _loadRaw(_prefs) ?? const {},
          ),
        );

  final SharedPreferences _prefs;

  static Map<String, dynamic>? _loadRaw(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  void _persist() {
    _prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  void recordAnswer({
    required String questionId,
    required int selectedAnswer,
    required int correctAnswer,
    required bool isCorrect,
    required String category,
    required String difficulty,
  }) {
    final categoryStats = Map<String, CategoryStat>.from(state.categoryStats);
    final stat = categoryStats[category] ?? CategoryStat(correct: 0, total: 0, accuracy: 0);
    final updatedStat = CategoryStat(
      correct: stat.correct + (isCorrect ? 1 : 0),
      total: stat.total + 1,
      accuracy: ((stat.correct + (isCorrect ? 1 : 0)) / (stat.total + 1) * 100).round(),
    );
    categoryStats[category] = updatedStat;

    final mastery = Map<String, String>.from(state.mastery);
    mastery[category] = _calculateMastery(updatedStat);

    final mistakes = List<MistakeRecord>.from(state.mistakes);
    final existingIdx = mistakes.indexWhere((m) => m.questionId == questionId);
    if (isCorrect) {
      if (existingIdx != -1) {
        final current = mistakes[existingIdx];
        if (current.correctStreak + 1 >= _masteryStreakThreshold) {
          mistakes.removeAt(existingIdx);
        } else {
          mistakes[existingIdx] = MistakeRecord(
            questionId: current.questionId,
            selectedAnswer: current.selectedAnswer,
            correctAnswer: current.correctAnswer,
            timestamp: current.timestamp,
            category: current.category,
            difficulty: current.difficulty,
            correctStreak: current.correctStreak + 1,
          );
        }
      }
    } else {
      if (existingIdx != -1) {
        final current = mistakes[existingIdx];
        mistakes[existingIdx] = MistakeRecord(
          questionId: current.questionId,
          selectedAnswer: selectedAnswer,
          correctAnswer: current.correctAnswer,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          category: current.category,
          difficulty: current.difficulty,
          correctStreak: 0,
        );
      } else {
        mistakes.add(MistakeRecord(
          questionId: questionId,
          selectedAnswer: selectedAnswer,
          correctAnswer: correctAnswer,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          category: category,
          difficulty: difficulty,
          correctStreak: 0,
        ));
      }
    }

    final reviewQueue = List<ReviewItem>.from(state.reviewQueue);
    final reviewIdx = reviewQueue.indexWhere((r) => r.questionId == questionId);
    final existingReview = reviewIdx == -1 ? null : reviewQueue[reviewIdx];
    final newReview = _calculateNextReview(existingReview, isCorrect, questionId);
    if (reviewIdx == -1) {
      reviewQueue.add(newReview);
    } else {
      reviewQueue[reviewIdx] = newReview;
    }

    final streak = Map<String, dynamic>.from(state.streak);
    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;
    if (streak['lastDate'] != today) {
      if (streak['lastDate'] == yesterday) {
        streak['current'] = (streak['current'] as int? ?? 0) + 1;
      } else {
        streak['current'] = 1;
      }
      streak['lastDate'] = today;
      streak['longest'] = (streak['longest'] as int? ?? 0);
      if ((streak['current'] as int) > (streak['longest'] as int)) {
        streak['longest'] = streak['current'];
      }
    }

    state = LearningState(
      mistakes: mistakes,
      categoryStats: categoryStats,
      reviewQueue: reviewQueue,
      mastery: mastery,
      streak: streak,
      totalAnswered: state.totalAnswered + 1,
      totalCorrect: state.totalCorrect + (isCorrect ? 1 : 0),
    );
    _persist();
  }

  List<String> getMistakeQuestions() => state.mistakes.map((m) => m.questionId).toList();

  List<String> getWeakCategories() {
    final entries = state.categoryStats.entries
        .where((e) => e.value.total >= 5 && e.value.accuracy < 70)
        .toList()
      ..sort((a, b) => a.value.accuracy.compareTo(b.value.accuracy));
    return entries.map((e) => e.key).toList();
  }

  List<String> getDueReviews() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final items = state.reviewQueue.where((r) => r.nextReviewDate <= now).toList()
      ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    return items.map((e) => e.questionId).toList();
  }

  void resetProgress() {
    state = LearningState(
      mistakes: const [],
      categoryStats: const {},
      reviewQueue: const [],
      mastery: const {},
      streak: const {'current': 0, 'lastDate': '', 'longest': 0},
      totalAnswered: 0,
      totalCorrect: 0,
    );
    _prefs.remove(_storageKey);
  }

  static String _calculateMastery(CategoryStat stats) {
    if (stats.total < 10) return 'beginner';
    if (stats.accuracy >= 80 && stats.total >= 20) return 'exam-ready';
    if (stats.accuracy >= 50) return 'intermediate';
    return 'beginner';
  }

  static ReviewItem _calculateNextReview(ReviewItem? item, bool isCorrect, String questionId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (item == null) {
      return ReviewItem(
        questionId: questionId,
        interval: isCorrect ? 1 : 0.5,
        easeFactor: 2.5,
        nextReviewDate: now + (isCorrect ? 86400000 : 43200000),
        repetitions: isCorrect ? 1 : 0,
      );
    }
    double interval = item.interval;
    double easeFactor = item.easeFactor;
    int repetitions = item.repetitions;
    if (isCorrect) {
      repetitions += 1;
      if (repetitions == 1) {
        interval = 1;
      } else if (repetitions == 2) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).roundToDouble();
      }
      easeFactor = (easeFactor + 0.1).clamp(1.3, 5.0);
    } else {
      repetitions = 0;
      interval = 0.5;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 5.0);
    }
    return ReviewItem(
      questionId: questionId,
      interval: interval,
      easeFactor: easeFactor,
      repetitions: repetitions,
      nextReviewDate: now + (interval * 86400000).round(),
    );
  }
}

final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LearningNotifier(prefs);
});
