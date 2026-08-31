import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/routes/journey_payloads.dart';
import '../../core/theme/modern_theme.dart';
import '../../data/models/curriculum_model.dart';
import '../../presentation/providers/curriculum_progress_provider.dart';
import '../../presentation/providers/curriculum_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_toast.dart';
import '../../widgets/smart_content_renderer.dart';
import '../../widgets/stagger_in.dart';

/// Reads one lesson (a handbook topic) inside the guided journey.
class LessonReaderScreen extends ConsumerWidget {
  const LessonReaderScreen({
    super.key,
    required this.module,
    required this.stage,
    required this.lesson,
  });

  final CurriculumModule module;
  final CurriculumStage stage;
  final CurriculumLesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(curriculumProgressProvider);
    final isDone = progress.completedLessons.contains(lesson.topicId);

    // Find next lesson for "Continue" button.
    final curriculum = ref.watch(curriculumProvider).valueOrNull;
    CurriculumLesson? nextLesson;
    if (curriculum != null) {
      final notifier = ref.read(curriculumProgressProvider.notifier);
      // Simulate this lesson being done to compute the real "next".
      final next = notifier.nextLesson(curriculum);
      if (next != null && next.topicId != lesson.topicId) {
        nextLesson = next;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'journey.lessonLabel'.tr(namedArgs: {'id': lesson.topicId}),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        actions: [
          Icon(
            isDone ? PhosphorIconsFill.checkCircle : PhosphorIcons.circle(),
            size: 20,
            color: isDone ? ModernTheme.emerald : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Hero
              StaggerIn(
                order: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stage.titleKey.tr(),
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            module.title,
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.9)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.title,
                      style: AppFonts.outfit(context,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(PhosphorIcons.clock(), size: 14, color: Colors.white.withValues(alpha: 0.85)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'learn.readTime'.tr(namedArgs: {'min': lesson.readTimeMinutes.toString()}),
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(PhosphorIcons.books(), size: 14, color: Colors.white.withValues(alpha: 0.85)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'learn.sectionsCount'.tr(namedArgs: {'count': (lesson.subtopics.length + (lesson.extraData.isNotEmpty ? 1 : 0)).toString()}),
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 28),

              if (lesson.extraData.isNotEmpty) ...[
                SmartContentRenderer(content: lesson.extraData),
                const SizedBox(height: 28),
              ],

              ...lesson.subtopics.asMap().entries.map((entry) {
                final idx = entry.key;
                final subtopic = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scheme.secondary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: AppFonts.outfit(context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                subtopic.title,
                                style: AppFonts.outfit(context,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    color: scheme.onSurface),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SmartContentRenderer(content: subtopic.contentData),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Complete button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    AppFeedback.tap(context);
                    ref
                        .read(curriculumProgressProvider.notifier)
                        .completeLesson(lesson.topicId);
                    _continueAfterComplete(context, nextLesson, module, stage);
                  },
                  icon: Icon(isDone
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsFill.check),
                  label: Text(
                    isDone
                        ? 'journey.completed'.tr()
                        : 'journey.completeLesson'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDone ? scheme.surfaceContainerHighest : scheme.primary,
                    foregroundColor: isDone ? ModernTheme.emerald : scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (isDone && nextLesson != null)
                _NextLessonButton(
                  nextLesson: nextLesson,
                  module: module,
                  stage: stage,
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _continueAfterComplete(
      BuildContext context, CurriculumLesson? nextLesson, CurriculumModule module, CurriculumStage stage) {
    showAppToast(context, 'journey.lessonCompleteMsg'.tr(), success: true);
    if (nextLesson != null) {
      // brief pause so the user sees the confirmation
      Future.delayed(const Duration(milliseconds: 600), () {
        if (context.mounted) {
          context.push('/journey/lesson',
              extra: LessonRoutePayload(module: module, stage: stage, lesson: nextLesson));
        }
      });
    }
  }
}

class _NextLessonButton extends StatelessWidget {
  const _NextLessonButton({
    required this.nextLesson,
    required this.module,
    required this.stage,
  });

  final CurriculumLesson nextLesson;
  final CurriculumModule module;
  final CurriculumStage stage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          AppFeedback.tap(context);
          context.pushReplacement('/journey/lesson',
              extra: LessonRoutePayload(
                  module: module, stage: stage, lesson: nextLesson));
        },
        icon: Icon(PhosphorIcons.arrowRight(), size: 18),
        label: Text(
          'journey.nextLesson'.tr(namedArgs: {'title': nextLesson.title}),
          style: AppFonts.outfit(context,
              fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}


