import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/curriculum_progress_repository.dart';
import '../../state/app_state.dart';
import '../../data/models/curriculum_model.dart';

final curriculumProgressRepositoryProvider =
    Provider<CurriculumProgressRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return CurriculumProgressRepository(prefs);
});

/// Tracks the user's progress through the guided curriculum:
/// completed lessons, best module quiz scores, and derived unlock state.
final curriculumProgressProvider =
    StateNotifierProvider<CurriculumProgressNotifier, CurriculumProgress>((ref) {
  final repo = ref.watch(curriculumProgressRepositoryProvider);
  return CurriculumProgressNotifier(repo);
});

class CurriculumProgress {
  const CurriculumProgress({
    this.completedLessons = const {},
    this.moduleBestScores = const {},
  });

  /// topicId -> marked read & lesson finished
  final Set<String> completedLessons;

  /// unitId -> best quiz percentage (0-100)
  final Map<int, int> moduleBestScores;

  bool isLessonComplete(String topicId) => completedLessons.contains(topicId);

  int bestScoreFor(int unitId) => moduleBestScores[unitId] ?? 0;

  bool isModuleQuizPassed(int unitId, {int passThreshold = 70}) =>
      (moduleBestScores[unitId] ?? 0) >= passThreshold;

  double moduleLessonProgress(CurriculumModule module) {
    if (module.lessons.isEmpty) return 0;
    final done = module.lessons.where((l) => completedLessons.contains(l.topicId)).length;
    return done / module.lessons.length;
  }

  bool isModuleComplete(CurriculumModule module, {int passThreshold = 70}) {
    final allRead = module.lessons.isNotEmpty &&
        module.lessons.every((l) => completedLessons.contains(l.topicId));
    final quizOk = !module.hasQuiz || isModuleQuizPassed(module.unitId, passThreshold: passThreshold);
    return allRead && quizOk;
  }

  CurriculumProgress copyWith({
    Set<String>? completedLessons,
    Map<int, int>? moduleBestScores,
  }) {
    return CurriculumProgress(
      completedLessons: completedLessons ?? this.completedLessons,
      moduleBestScores: moduleBestScores ?? this.moduleBestScores,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLessons': completedLessons.toList(),
        'moduleBestScores': moduleBestScores.map((k, v) => MapEntry(k.toString(), v)),
      };

  static CurriculumProgress fromJson(Map<String, dynamic> json) {
    return CurriculumProgress(
      completedLessons: (json['completedLessons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      moduleBestScores: (json['moduleBestScores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.tryParse(k) ?? 0, (v as num).toInt())) ??
          {},
    );
  }
}

class CurriculumProgressNotifier extends StateNotifier<CurriculumProgress> {
  CurriculumProgressNotifier(this._repo)
      : super(CurriculumProgress.fromJson(_repo.loadProgress()));

  final CurriculumProgressRepository _repo;

  /// Marks a lesson complete and persists.
  void completeLesson(String topicId) {
    state = state.copyWith(completedLessons: {...state.completedLessons, topicId});
    _repo.saveProgress(state.toJson());
  }

  /// Records the best quiz score for a module (unitId).
  void recordModuleQuizScore(int unitId, int percentage) {
    final best = state.bestScoreFor(unitId);
    if (percentage <= best) return;
    state = state.copyWith(
      moduleBestScores: {...state.moduleBestScores, unitId: percentage},
    );
    _repo.saveProgress(state.toJson());
  }

  void reset() {
    state = const CurriculumProgress();
    _repo.saveProgress(state.toJson());
  }

  /// Whether a module is unlocked (previous module complete, first always open).
  bool isModuleUnlocked(CurriculumModule module, Curriculum curriculum) {
    final allModules = curriculum.allModules;
    final index = allModules.indexWhere((m) => m.unitId == module.unitId);
    if (index <= 0) return true;
    final previous = allModules[index - 1];
    return state.isModuleComplete(previous);
  }

  /// The next step the user should take (deep-first across stages/modules).
  ///
  /// Returns the next incomplete lesson, or null when the user should take the
  /// module quiz instead (all lessons read, quiz not yet passed).
  CurriculumLesson? nextLesson(Curriculum curriculum) {
    for (final stage in curriculum.stages) {
      for (final module in stage.modules) {
        if (!isModuleUnlocked(module, curriculum)) {
          // locked module: surface its first lesson as the next goal
          return module.lessons.isNotEmpty ? module.lessons.first : null;
        }
        for (final lesson in module.lessons) {
          if (!state.completedLessons.contains(lesson.topicId)) {
            return lesson;
          }
        }
        // All lessons read — quiz is the remaining step for this module.
        if (module.hasQuiz && !state.isModuleQuizPassed(module.unitId)) {
          return null;
        }
      }
    }
    return null;
  }

  /// The module containing [lesson].
  (CurriculumModule, CurriculumStage)? findModuleAndStage(
      Curriculum curriculum, CurriculumLesson lesson) {
    for (final stage in curriculum.stages) {
      for (final module in stage.modules) {
        if (module.lessons.any((l) => l.topicId == lesson.topicId)) {
          return (module, stage);
        }
      }
    }
    return null;
  }
}
