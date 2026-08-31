import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../state/app_state.dart';
import '../../../state/learning_state.dart';
import '../../../utils/app_fonts.dart';
import '../../../widgets/home_shell.dart';
import 'widgets/home_action_grid.dart';
import 'widgets/home_compact_stats_bar.dart';
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
    final settings = ref.watch(appSettingsProvider);
    final stats = settings.stats;
    final learning = ref.watch(learningProvider);

    final totalAnswered = stats.totalAnswered;
    final accuracy = totalAnswered == 0
        ? 0
        : ((stats.totalCorrect / totalAnswered) * 100).round();
    final streak = learning.streak['current'] as int? ?? 0;

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            cacheExtent: 1200,
            slivers: [
              // Header / Greeting & Actions
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'home.greeting'.tr(),
                                  style: AppFonts.outfit(
                                    context,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  PhosphorIconsRegular.calendarBlank,
                                  size: 13,
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _formatDate(context),
                                  style: AppFonts.outfit(
                                    context,
                                    fontSize: 13,
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            key: const Key('home_action_settings'),
                            onPressed: () => _goSettings(context),
                            icon: const Icon(PhosphorIconsRegular.gear, size: 22),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                                  : scheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : scheme.outline.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Compact Stats Bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                sliver: SliverToBoxAdapter(
                  child: _StaggerIn(
                    order: 0,
                    child: HomeCompactStatsBar(
                      streak: streak,
                      accuracy: accuracy,
                    ),
                  ),
                ),
              ),

              // Learning Paths Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: _StaggerIn(
                    order: 1,
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
                          onTapHandbook: () => context.push('/learn'),
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
                  child: _StaggerIn(
                    order: 2,
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

class _QuickPracticeBanner extends StatelessWidget {
  const _QuickPracticeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.65)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : scheme.outline.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
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
                      color: ModernTheme.emerald.withValues(alpha: 0.3),
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

class _StaggerIn extends StatelessWidget {
  const _StaggerIn({required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = 40 * order;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 240 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      child: child,
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: builtChild,
          ),
        );
      },
    );
  }
}
