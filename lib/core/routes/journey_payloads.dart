import '../../data/models/curriculum_model.dart';

/// Route payload carrying a lesson's module/stage/lesson context.
class LessonRoutePayload {
  const LessonRoutePayload({
    required this.module,
    required this.stage,
    required this.lesson,
  });

  final CurriculumModule module;
  final CurriculumStage stage;
  final CurriculumLesson lesson;
}

/// Route payload carrying a module's stage/module context.
class ModuleRoutePayload {
  const ModuleRoutePayload({required this.stage, required this.module});

  final CurriculumStage stage;
  final CurriculumModule module;
}
