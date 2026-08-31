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
import '../../widgets/confetti_overlay.dart';
import '../../widgets/stagger_in.dart';

/// The guided learning journey: staged modules the user completes in order.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculumAsync = ref.watch(curriculumProvider);
    final progress = ref.watch(curriculumProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'journey.title'.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'journey.reset'.tr(),
            icon: Icon(PhosphorIcons.arrowCounterClockwise(),
                color: scheme.onSurfaceVariant),
            onPressed: () => _confirmReset(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: curriculumAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.warningCircle(), size: 56, color: scheme.error),
                    const SizedBox(height: 16),
                    Text('${'journey.errorLoading'.tr()}: $err',
                        textAlign: TextAlign.center,
                        style: AppFonts.outfit(context,
                            fontSize: 14, color: scheme.onSurface)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(curriculumProvider),
                      icon: Icon(PhosphorIcons.arrowsClockwise()),
                      label: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
            data: (curriculum) {
              final nextLesson =
                  ref.read(curriculumProgressProvider.notifier).nextLesson(curriculum);
              final doneLessons = progress.completedLessons.length;
              final totalLessons = curriculum.totalLessons;
              final overall =
                  totalLessons == 0 ? 0.0 : doneLessons / totalLessons;
              final allDone =
                  totalLessons > 0 && doneLessons == totalLessons;

              final content = ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  StaggerIn(
                    order: 0,
                    child: _JourneyHero(
                      overall: overall,
                      doneLessons: doneLessons,
                      totalLessons: totalLessons,
                      totalModules: curriculum.totalModules,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (nextLesson != null)
                    StaggerIn(
                      order: 1,
                      child: _ContinueLearningCard(
                        lesson: nextLesson,
                        onTap: () => _openLesson(context, ref, curriculum, nextLesson),
                      ),
                    )
                  else if (doneLessons > 0 && totalLessons > 0)
                    StaggerIn(
                      order: 1,
                      child: _JourneyCompleteCard(
                        onTap: () => context.push('/exam'),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ...curriculum.stages.asMap().entries.map((stageEntry) {
                    final stageIndex = stageEntry.key;
                    final stage = stageEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: StaggerIn(
                        order: stageIndex + 2,
                        child: _StageSection(
                          stage: stage,
                          curriculum: curriculum,
                        ),
                      ),
                    );
                  }),
                ],
              );

              if (allDone) {
                return ConfettiOverlay(autoStart: true, child: content);
              }
              return content;
            },
          ),
        ),
      ),
    );
  }

  void _openLesson(
      BuildContext context, WidgetRef ref, Curriculum curriculum, CurriculumLesson lesson) {
    AppFeedback.tap(context);
    final notifier = ref.read(curriculumProgressProvider.notifier);
    final found = notifier.findModuleAndStage(curriculum, lesson);
    if (found == null) return;
    final (module, stage) = found;
    context.push('/journey/lesson',
        extra: LessonRoutePayload(module: module, stage: stage, lesson: lesson));
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('journey.reset'.tr()),
        content: Text('journey.resetConfirm'.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              ref.read(curriculumProgressProvider.notifier).reset();
              Navigator.pop(ctx);
            },
            child: Text('journey.reset'.tr()),
          ),
        ],
      ),
    );
  }
}


class _JourneyHero extends StatelessWidget {
  const _JourneyHero({
    required this.overall,
    required this.doneLessons,
    required this.totalLessons,
    required this.totalModules,
  });

  final double overall;
  final int doneLessons;
  final int totalLessons;
  final int totalModules;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: overall,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${(overall * 100).round()}%',
                  style: AppFonts.outfit(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'journey.heroTitle'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'journey.heroSubtitle'.tr(namedArgs: {
                    'lessons': doneLessons.toString(),
                    'total': totalLessons.toString(),
                  }),
                  style: AppFonts.outfit(context,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 4),
                Text(
                  'journey.heroModules'.tr(namedArgs: {'count': totalModules.toString()}),
                  style: AppFonts.outfit(context,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.lesson, required this.onTap});

  final CurriculumLesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(PhosphorIconsFill.play, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'journey.continueTitle'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.title,
                    style: AppFonts.outfit(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: scheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'journey.continueSubtitle'.tr(namedArgs: {
                      'min': lesson.readTimeMinutes.toString(),
                    }),
                    style: AppFonts.outfit(context,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

class _JourneyCompleteCard extends StatelessWidget {
  const _JourneyCompleteCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: ModernTheme.emeraldGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.emerald.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsFill.trophy,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'journey.allComplete'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'journey.allCompleteDesc'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageSection extends ConsumerWidget {
  const _StageSection({required this.stage, required this.curriculum});

  final CurriculumStage stage;
  final Curriculum curriculum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(curriculumProgressProvider);
    final notifier = ref.read(curriculumProgressProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: _stageGradient(stage.id),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                stage.titleKey.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          stage.subtitleKey.tr(),
          style: AppFonts.outfit(context,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        ...stage.modules.map((module) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ModuleCard(
              module: module,
              curriculum: curriculum,
              progress: progress,
              unlocked: notifier.isModuleUnlocked(module, curriculum),
              onTap: () {
                AppFeedback.tap(context);
                context.push('/journey/module',
                    extra: ModuleRoutePayload(stage: stage, module: module));
              },
            ),
          );
        }),
      ],
    );
  }

  LinearGradient _stageGradient(int stageId) {
    switch (stageId) {
      case 1:
        return ModernTheme.primaryGradient;
      case 2:
        return ModernTheme.emeraldGradient;
      case 3:
        return ModernTheme.electricCyanGradient;
      case 4:
        return ModernTheme.goldMetallicGradient;
      default:
        return ModernTheme.royalEmeraldGradient;
    }
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.curriculum,
    required this.progress,
    required this.unlocked,
    required this.onTap,
  });

  final CurriculumModule module;
  final Curriculum curriculum;
  final CurriculumProgress progress;
  final bool unlocked;
  final VoidCallback onTap;

  IconData _iconForUnit(int unitId) {
    switch (unitId) {
      case 1:
        return PhosphorIconsFill.identificationCard;
      case 2:
        return PhosphorIconsFill.carProfile;
      case 3:
        return PhosphorIconsFill.trafficSign;
      case 4:
        return PhosphorIconsFill.gitMerge;
      case 5:
        return PhosphorIconsFill.gauge;
      case 6:
        return PhosphorIconsFill.warningCircle;
      default:
        return PhosphorIconsFill.bookOpen;
    }
  }

  Color _colorForUnit(int unitId) {
    switch (unitId) {
      case 1:
        return Colors.blue.shade600;
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.orange.shade700;
      case 4:
        return Colors.purple.shade500;
      case 5:
        return Colors.red.shade600;
      case 6:
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorForUnit(module.unitId);

    final doneLessons = module.lessons
        .where((l) => progress.completedLessons.contains(l.topicId))
        .length;
    final lessonProgress =
        module.lessons.isEmpty ? 0.0 : doneLessons / module.lessons.length;
    final isComplete = progress.isModuleComplete(module);
    final quizPassed = !module.hasQuiz || progress.isModuleQuizPassed(module.unitId);

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isComplete
                  ? color.withValues(alpha: 0.6)
                  : scheme.onSurface.withValues(alpha: 0.06),
              width: isComplete ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  unlocked
                      ? (isComplete ? PhosphorIconsFill.checkCircle : _iconForUnit(module.unitId))
                      : PhosphorIcons.lockSimple(),
                  color: isComplete ? color : (unlocked ? color : scheme.onSurfaceVariant),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: AppFonts.outfit(context,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: scheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(PhosphorIcons.books(), size: 13,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'journey.lessonCount'.tr(namedArgs: {
                            'done': doneLessons.toString(),
                            'total': module.lessons.length.toString(),
                          }),
                          style: AppFonts.outfit(context,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant),
                        ),
                        if (module.hasQuiz) ...[
                          const SizedBox(width: 10),
                          Icon(PhosphorIcons.student(), size: 13,
                              color: quizPassed
                                  ? ModernTheme.emerald
                                  : scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            quizPassed
                                ? 'journey.quizPassed'.tr()
                                : 'journey.quizPending'.tr(),
                            style: AppFonts.outfit(context,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: quizPassed
                                    ? ModernTheme.emerald
                                    : scheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lessonProgress,
                        minHeight: 5,
                        backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isComplete ? color : scheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                unlocked
                    ? Icons.arrow_forward_ios_rounded
                    : PhosphorIcons.lockSimple(),
                size: unlocked ? 16 : 18,
                color: unlocked
                    ? scheme.onSurface.withValues(alpha: 0.25)
                    : scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



