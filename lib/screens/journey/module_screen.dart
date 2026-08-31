import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/routes/journey_payloads.dart';
import '../../core/theme/modern_theme.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/models/handbook_model.dart';
import '../../presentation/providers/curriculum_progress_provider.dart';
import '../../presentation/providers/handbook_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/app_fonts.dart';
import '../../widgets/stagger_in.dart';

/// Lists the lessons inside one curriculum module and its comprehension quiz.
class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.stage, required this.module});

  final CurriculumStage stage;
  final CurriculumModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(curriculumProgressProvider);

    final doneLessons = module.lessons
        .where((l) => progress.completedLessons.contains(l.topicId))
        .length;
    final lessonProgress =
        module.lessons.isEmpty ? 0.0 : doneLessons / module.lessons.length;
    final allRead = module.lessons.isNotEmpty &&
        module.lessons.every((l) => progress.completedLessons.contains(l.topicId));
    final quizPassed = !module.hasQuiz || progress.isModuleQuizPassed(module.unitId);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          stage.titleKey.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Module hero
              StaggerIn(
                order: 0,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'journey.unitLabel'.tr(namedArgs: {'id': module.unitId.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        module.title,
                        style: AppFonts.outfit(context,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(PhosphorIcons.books(), size: 16, color: Colors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 6),
                          Text(
                            'journey.lessonCount'.tr(namedArgs: {
                              'done': doneLessons.toString(),
                              'total': module.lessons.length.toString(),
                            }),
                            style: AppFonts.outfit(context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: lessonProgress,
                                minHeight: 5,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              StaggerIn(
                order: 1,
                child: Text(
                  'journey.lessonsHeader'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface),
                ),
              ),
              const SizedBox(height: 14),

              // Lesson list
              ...module.lessons.asMap().entries.map((entry) {
                final index = entry.key;
                final lesson = entry.value;
                final isDone = progress.completedLessons.contains(lesson.topicId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StaggerIn(
                    order: index + 2,
                    child: _LessonTile(
                      index: index + 1,
                      lesson: lesson,
                      isDone: isDone,
                      onTap: () {
                        AppFeedback.tap(context);
                        context.push('/journey/lesson',
                            extra: LessonRoutePayload(
                                module: module, stage: stage, lesson: lesson));
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Comprehension quiz card
              if (module.hasQuiz) ...[
                StaggerIn(
                  order: module.lessons.length + 2,
                  child: _QuizCard(
                    module: module,
                    allRead: allRead,
                    quizPassed: quizPassed,
                    bestScore: progress.bestScoreFor(module.unitId),
                    onTap: !allRead
                        ? null
                        : () {
                            AppFeedback.tap(context);
                            context.push('/journey/quiz',
                                extra: ModuleRoutePayload(stage: stage, module: module));
                          },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Reference handbook link
              StaggerIn(
                order: module.lessons.length + 3,
                child: _HandbookUnitLink(module: module),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandbookUnitLink extends ConsumerWidget {
  const _HandbookUnitLink({required this.module});

  final CurriculumModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final info = ref.watch(handbookInfoProvider);

    return InkWell(
      onTap: () {
        AppFeedback.tap(context);
        HandbookUnit? unit;
        for (final u in info.valueOrNull?.units ?? const <HandbookUnit>[]) {
          if (u.unitId == module.unitId) {
            unit = u;
            break;
          }
        }
        if (unit != null) {
          context.push('/learn/unit', extra: unit);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsFill.bookOpen, color: scheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'journey.openHandbook'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: scheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.isDone,
    required this.onTap,
  });

  final int index;
  final CurriculumLesson lesson;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDone
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? Icon(PhosphorIcons.check(), color: Colors.white, size: 18)
                    : Text(
                        '$index',
                        style: AppFonts.outfit(context,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: scheme.primary),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppFonts.outfit(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: scheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(PhosphorIcons.clock(), size: 13,
                          color: scheme.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'learn.readTime'.tr(namedArgs: {'min': lesson.readTimeMinutes.toString()}),
                        style: AppFonts.outfit(context,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: scheme.onSurface.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.module,
    required this.allRead,
    required this.quizPassed,
    required this.bestScore,
    required this.onTap,
  });

  final CurriculumModule module;
  final bool allRead;
  final bool quizPassed;
  final int bestScore;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = quizPassed ? ModernTheme.emerald : ModernTheme.amber;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: isDark ? 0.18 : 0.12),
              color.withValues(alpha: isDark ? 0.08 : 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                quizPassed ? PhosphorIconsFill.sealCheck : PhosphorIconsFill.student,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizPassed ? 'journey.quizPassed'.tr() : 'journey.quizTitle'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    quizPassed
                        ? 'journey.quizPassedDesc'.tr(namedArgs: {'score': bestScore.toString()})
                        : (allRead
                            ? 'journey.quizReadyDesc'.tr(namedArgs: {
                                'count': module.quizQuestions.length.toString()
                              })
                            : 'journey.quizLockedDesc'.tr()),
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              quizPassed
                  ? PhosphorIcons.checkCircle()
                  : (!allRead
                      ? PhosphorIcons.lockSimple()
                      : Icons.arrow_forward_ios_rounded),
              color: color,
              size: quizPassed ? 24 : 18,
            ),
          ],
        ),
      ),
    );
  }
}

