import '../../models/question.dart';
import 'handbook_model.dart';

/// A comprehension-check question pulled from the handbook quiz bank.
class CurriculumQuizQuestion {
  const CurriculumQuizQuestion({
    required this.id,
    required this.unit,
    required this.topic,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  final String id;
  final int unit;
  final String topic;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  int get correctIndex {
    final idx = options.indexOf(correctAnswer);
    return idx < 0 ? 0 : idx;
  }

  factory CurriculumQuizQuestion.fromJson(Map<String, dynamic> json) {
    return CurriculumQuizQuestion(
      id: json['id']?.toString() ?? '',
      unit: (json['unit'] as num?)?.toInt() ?? 0,
      topic: json['topic']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctAnswer: json['correct_answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

/// A single lesson inside a module. Maps to one handbook topic.
class CurriculumLesson {
  const CurriculumLesson({
    required this.topicId,
    required this.title,
    required this.subtopics,
    required this.extraData,
    required this.readTimeMinutes,
  });

  final String topicId;
  final String title;
  final List<HandbookSubtopic> subtopics;

  /// Stray keys stored directly on the topic object (e.g. tables).
  final Map<String, dynamic> extraData;

  /// Rough reading estimate derived from content sections.
  final int readTimeMinutes;

  factory CurriculumLesson.fromTopic(HandbookTopic topic) {
    int sections = topic.subtopics.length + (topic.extraData.isNotEmpty ? 1 : 0);
    return CurriculumLesson(
      topicId: topic.topicId,
      title: topic.title,
      subtopics: topic.subtopics,
      extraData: topic.extraData,
      readTimeMinutes: sections < 1 ? 1 : sections * 2,
    );
  }
}

/// A module in the journey. Maps to one handbook unit.
class CurriculumModule {
  const CurriculumModule({
    required this.unitId,
    required this.title,
    required this.order,
    required this.lessons,
    required this.quizQuestions,
  });

  final int unitId;
  final String title;
  final int order;
  final List<CurriculumLesson> lessons;
  final List<CurriculumQuizQuestion> quizQuestions;

  bool get hasQuiz => quizQuestions.isNotEmpty;
}

/// A named phase of the journey containing ordered modules.
class CurriculumStage {
  const CurriculumStage({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.modules,
  });

  final int id;
  final String titleKey;
  final String subtitleKey;
  final List<CurriculumModule> modules;
}

/// The full guided curriculum built from handbook + quiz bank.
class Curriculum {
  const Curriculum({required this.stages});

  final List<CurriculumStage> stages;

  int get totalLessons => stages
      .fold<int>(0, (sum, s) => sum + s.modules.fold<int>(0, (m, mod) => m + mod.lessons.length));

  int get totalModules =>
      stages.fold<int>(0, (sum, s) => sum + s.modules.length);

  List<CurriculumModule> get allModules =>
      [for (final s in stages) ...s.modules];
}

/// Maps a handbook `Question` into the quiz-bank question shape so modules with
/// an empty quiz bank can fall back to the main question bank.
List<CurriculumQuizQuestion> questionsFromQuestionBank(List<Question> questions) {
  return questions.map((q) {
    final text = q.questionText ?? q.questionKey;
    return CurriculumQuizQuestion(
      id: q.id,
      unit: 0,
      topic: '',
      question: text,
      options: q.options ?? q.optionsKeys,
      correctAnswer: q.options != null && q.options!.isNotEmpty
          ? (q.correctIndex < q.options!.length ? q.options![q.correctIndex] : '')
          : (q.optionsKeys.isNotEmpty
              ? (q.correctIndex < q.optionsKeys.length ? q.optionsKeys[q.correctIndex] : '')
              : ''),
      explanation: q.explanation ?? q.explanationKey ?? '',
    );
  }).toList();
}
