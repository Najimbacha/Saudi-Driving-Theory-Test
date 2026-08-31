import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/curriculum_model.dart';
import '../../state/data_state.dart';
import 'handbook_provider.dart';

/// Builds the guided [Curriculum] from the localized handbook + quiz bank.
///
/// Handbook units are grouped into learning stages ordered from beginner to
/// exam-ready. Each unit becomes a module; each topic a lesson. Comprehension
/// questions come from the handbook quiz bank for that unit, falling back to
/// the main question bank when a unit has no quiz entries.
final curriculumProvider = FutureProvider<Curriculum>((ref) async {
  final handbook = await ref.watch(handbookProvider.future);

  // Quiz bank lives at the root extraData (extracted from app_data).
  final quizBankRaw = handbook.extraData['quiz_bank'];
  final List<Map<String, dynamic>> quizBank = [];
  if (quizBankRaw is List) {
    for (final item in quizBankRaw) {
      if (item is Map) {
        quizBank.add(Map<String, dynamic>.from(item));
      }
    }
  }

  // Fallback question bank — loaded lazily only if a unit lacks quiz entries.
  final units = handbook.appData.units;

  // Stage grouping: [stageTitleKey, stageSubtitleKey, unitIndexes...]
  const stageLayout = [
    {
      'titleKey': 'journey.stage1.title',
      'subtitleKey': 'journey.stage1.subtitle',
      'units': [0],
    },
    {
      'titleKey': 'journey.stage2.title',
      'subtitleKey': 'journey.stage2.subtitle',
      'units': [1],
    },
    {
      'titleKey': 'journey.stage3.title',
      'subtitleKey': 'journey.stage3.subtitle',
      'units': [2, 3],
    },
    {
      'titleKey': 'journey.stage4.title',
      'subtitleKey': 'journey.stage4.subtitle',
      'units': [4],
    },
    {
      'titleKey': 'journey.stage5.title',
      'subtitleKey': 'journey.stage5.subtitle',
      'units': [5],
    },
  ];

  final stages = <CurriculumStage>[];
  var moduleOrder = 0;
  List<CurriculumQuizQuestion>? fallbackQuestions;

  for (final stage in stageLayout) {
    final unitIndexes = stage['units'] as List<int>;
    final modules = <CurriculumModule>[];

    for (final idx in unitIndexes) {
      if (idx >= units.length) continue;
      final unit = units[idx];
      moduleOrder += 1;

      final unitQuiz =
          quizBank.where((q) => (q['unit'] as num?)?.toInt() == unit.unitId).toList();

      var quizQuestions = unitQuiz.map(CurriculumQuizQuestion.fromJson).toList();

      // Fallback: if a unit has no quiz-bank entries, derive questions from the
      // main bank. Loaded lazily so the common path never waits on it.
      if (quizQuestions.isEmpty) {
        fallbackQuestions ??= questionsFromQuestionBank(
          await ref.watch(questionsProvider.future),
        );
        quizQuestions = fallbackQuestions;
      }

      modules.add(CurriculumModule(
        unitId: unit.unitId,
        title: unit.title,
        order: moduleOrder,
        lessons: unit.topics.map(CurriculumLesson.fromTopic).toList(),
        quizQuestions: quizQuestions,
      ));
    }

    if (modules.isEmpty) continue;

    stages.add(CurriculumStage(
      id: stages.length + 1,
      titleKey: stage['titleKey'] as String,
      subtitleKey: stage['subtitleKey'] as String,
      modules: modules,
    ));
  }

  return Curriculum(stages: stages);
});
