import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../state/learning_state.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
import '../../../widgets/banner_ad_widget.dart';
import '../../../widgets/home_shell.dart';
import '../../../widgets/stagger_in.dart';
import '../../providers/curriculum_progress_provider.dart';
import '../../providers/curriculum_provider.dart';
import 'widgets/home_action_grid.dart';
import 'widgets/home_hero_goal_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  static String _formatDate(BuildContext context) {
    try {
      return DateFormat('EEEE, d MMM', context.locale.toString())
          .format(DateTime.now());
    } catch (_) {
      final now = DateTime.now();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _HomeAppBar(onSettings: () => _goSettings(context)),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            cacheExtent: 1600,
            slivers: [
              // Header / Date
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: StaggerIn(
                    order: 0,
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.calendarBlank,
                          size: 13,
                          color: scheme.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(context),
                          style: AppFonts.outfit(
                            context,
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Guided Learning Journey - Continue card
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: StaggerIn(
                    order: 1,
                    child: _JourneyContinueCard(),
                  ),
                ),
              ),

              // Learning Paths Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: StaggerIn(
                    order: 2,
                    child: Column(
                      key: const Key('home_section_learning_paths'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              PhosphorIconsFill.compass,
                              size: 18,
                              color: ModernTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'home.learningPaths'.tr(),
                              style: AppFonts.outfit(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        HomeActionGrid(
                          onTapCategories: () => context.push('/categories'),
                          onTapHandbook: () => context.push('/journey'),
                          onTapSigns: () => _goSigns(context),
                          onTapStats: () => context.push('/stats'),
                          onTapHistory: () => context.push('/history'),
                          onTapViolations: () =>
                              context.push('/violation-points'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Start & Exam Hero Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: StaggerIn(
                    order: 3,
                    child: Column(
                      key: const Key('home_section_quick_start'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              PhosphorIconsFill.lightning,
                              size: 18,
                              color: ModernTheme.amber,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'home.quickStart'.tr(),
                              style: AppFonts.outfit(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _QuickPracticeBanner(
                          onTap: () => _goPractice(context),
                        ),
                        const SizedBox(height: 12),
                        HomeHeroGoalCard(
                          title: 'Full Practice Exam',
                          subtitle: 'home.mockExamDesc'.tr(),
                          ctaText: 'home.examSimCta'.tr(),
                          onTap: () => _goExam(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // Subtle banner ad (only when enabled in settings)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(child: BannerAdWidget()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goPractice(BuildContext context) {
    final shell = TabShellScope.maybeOf(context);
    if (shell != null) {
      shell.value = 2;
    } else {
      context.push('/practice');
    }
  }

  void _goExam(BuildContext context) {
    final shell = TabShellScope.maybeOf(context);
    if (shell != null) {
      shell.value = 3;
    } else {
      context.push('/exam');
    }
  }

  void _goSigns(BuildContext context) {
    final shell = TabShellScope.maybeOf(context);
    if (shell != null) {
      shell.value = 1;
    } else {
      context.push('/signs');
    }
  }

  void _goSettings(BuildContext context) {
    final shell = TabShellScope.maybeOf(context);
    if (shell != null) {
      shell.value = 4;
    } else {
      context.push('/settings');
    }
  }
}

class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _HomeAppBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final streak =
        ref.watch(learningProvider).streak['current'] as int? ?? 0;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsFill.steeringWheel,
              size: 21,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'app.nameShort'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: ModernTheme.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ModernTheme.amber.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsFill.fire, size: 15, color: ModernTheme.amber),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: AppFonts.outfit(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ModernTheme.amber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const _LevelBadge(),
        const SizedBox(width: 10),
        IconButton(
          key: const Key('home_action_settings'),
          onPressed: onSettings,
          icon: const Icon(PhosphorIconsRegular.gear, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                : scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : scheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _LevelBadge extends ConsumerWidget {
  const _LevelBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final progress = ref.watch(curriculumProgressProvider);
    final curriculum = ref.watch(curriculumProvider).valueOrNull;
    final total = curriculum?.totalLessons ?? 0;
    final done = total == 0 ? 0 : progress.completedLessons.length;
    final pct = total == 0 ? 0.0 : done / total;
    final level = _levelForProgress(pct);
    final label = _levelLabelKey(level).tr();

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: _levelGradient(level),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Tooltip(
        message: label,
        child: const Icon(
          PhosphorIconsFill.sealCheck,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  static int _levelForProgress(double pct) {
    if (pct >= 0.9) return 5;
    if (pct >= 0.6) return 4;
    if (pct >= 0.3) return 3;
    if (pct > 0) return 2;
    return 1;
  }

  static String _levelLabelKey(int level) {
    switch (level) {
      case 5:
        return 'home.levels.expert';
      case 4:
        return 'home.levels.proficient';
      case 3:
        return 'home.levels.learner';
      case 2:
        return 'home.levels.begun';
      default:
        return 'home.levels.start';
    }
  }

  static LinearGradient _levelGradient(int level) {
    switch (level) {
      case 5:
        return ModernTheme.goldMetallicGradient;
      case 4:
        return ModernTheme.emeraldGradient;
      case 3:
        return ModernTheme.electricCyanGradient;
      case 2:
        return ModernTheme.primaryGradient;
      default:
        return const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

class _QuickPracticeBanner extends StatelessWidget {
  const _QuickPracticeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'home.practice'.tr(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernTheme.emerald.withValues(alpha: 0.14),
                ModernTheme.tertiary.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ModernTheme.emerald.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernTheme.emerald.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ModernTheme.emeraldGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ModernTheme.emerald.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  PhosphorIconsFill.checks,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.practice'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'home.practiceDesc'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernTheme.emerald.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: ModernTheme.emerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyContinueCard extends ConsumerWidget {
  const _JourneyContinueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final curriculumAsync = ref.watch(curriculumProvider);
    final progress = ref.watch(curriculumProgressProvider);
    final curriculum = curriculumAsync.valueOrNull;
    if (curriculum == null) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(curriculumProgressProvider.notifier);
    final nextLesson = notifier.nextLesson(curriculum);
    final total = curriculum.totalLessons;
    final overall = total == 0 ? 0.0 : progress.completedLessons.length / total;

    final title = nextLesson != null
        ? nextLesson.title
        : 'home.journeyComplete'.tr();
    final subtitle = nextLesson != null
        ? 'home.continueLesson'.tr(namedArgs: {
            'min': nextLesson.readTimeMinutes.toString(),
          })
        : 'home.journeyCompleteDesc'.tr();

    return InkWell(
      key: const Key('home_journey_continue'),
      onTap: () {
        AppFeedback.tap(context);
        context.push('/journey');
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF6366F1),
              Color(0xFF7C3AED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: ModernTheme.secondary.withValues(alpha: 0.18),
              blurRadius: 36,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative orbs
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ModernTheme.secondary.withValues(alpha: 0.18),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: CircularProgressIndicator(
                          value: overall,
                          strokeWidth: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          nextLesson != null
                              ? PhosphorIconsFill.play
                              : PhosphorIconsFill.sealCheck,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'home.continueLearning.title'.tr(),
                              style: AppFonts.outfit(
                                context,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(overall * 100).round()}%',
                            style: AppFonts.outfit(
                              context,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppFonts.outfit(
                          context,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(PhosphorIcons.clock(),
                              size: 12, color: Colors.white.withValues(alpha: 0.85)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              subtitle,
                              style: AppFonts.outfit(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
