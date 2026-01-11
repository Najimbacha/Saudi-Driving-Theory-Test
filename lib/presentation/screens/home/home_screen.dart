import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/home_shell.dart';
import '../../../state/app_state.dart';
import '../../../state/learning_state.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(appSettingsProvider).stats;
    final learning = ref.watch(learningProvider);

    // Calculate stats
    final totalAnswered = stats.totalAnswered;
    final accuracy = totalAnswered == 0
        ? 0
        : ((stats.totalCorrect / totalAnswered) * 100).round();
    final streak = learning.streak['current'] ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow glass effect to overlap content
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? ModernTheme.darkGradient
              : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            cacheExtent: 800,
            slivers: [
              // Hero Section with Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: _GlassHeroSection(
                    totalAnswered: totalAnswered,
                    accuracy: accuracy,
                    streak: streak,
                  ),
                ),
              ),

              // Quick Actions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'home.quickStart'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Quick Actions Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _GlassActionCard(
                          title: 'home.practice'.tr(),
                          subtitle: 'home.practiceSubtitle'.tr(),
                          icon: PhosphorIconsRegular.playCircle,
                          color: ModernTheme.primary,
                          gradient: ModernTheme.primaryGradient,
                          onTap: () {
                            final shell = TabShellScope.maybeOf(context);
                            if (shell != null) {
                              shell.value = 2;
                            } else {
                              context.push('/practice');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GlassActionCard(
                          title: 'home.mockExam'.tr(),
                          subtitle: 'home.mockExamSubtitle'.tr(),
                          icon: PhosphorIconsRegular.timer,
                          color: ModernTheme.secondary,
                          gradient: ModernTheme.accentGradient,
                          onTap: () {
                            final shell = TabShellScope.maybeOf(context);
                            if (shell != null) {
                              shell.value = 3;
                            } else {
                              context.push('/exam');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Learning Paths Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'home.learningPaths'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Vertical List of Paths
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _GlassListTile(
                      title: 'home.practiceByCategory'.tr(),
                      subtitle: 'home.practiceByCategoryDesc'.tr(),
                      icon: PhosphorIconsRegular.gridFour,
                      color: Colors.blueAccent,
                      onTap: () => context.push('/categories'),
                    ),
                    const SizedBox(height: 12),
                    _GlassListTile(
                      title: 'home.learnSigns'.tr(),
                      subtitle: 'home.learnSignsDesc'.tr(),
                      icon: PhosphorIconsRegular.trafficSign,
                      color: Colors.amber,
                      onTap: () {
                        final shell = TabShellScope.maybeOf(context);
                        if (shell != null) {
                          shell.value = 1;
                        } else {
                          context.push('/signs');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _GlassListTile(
                      title: 'home.stats'.tr(),
                      subtitle: 'home.statsDesc'.tr(),
                      icon: PhosphorIconsRegular.chartBar,
                      color: ModernTheme.tertiary,
                      onTap: () => context.push('/stats'),
                    ),
                    const SizedBox(height: 12),
                    _GlassListTile(
                      title: 'home.history'.tr(),
                      subtitle: 'home.historyDesc'.tr(),
                      icon: PhosphorIconsRegular.clockCounterClockwise,
                      color: Colors.white70,
                      onTap: () => context.push('/history'),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassHeroSection extends StatelessWidget {
  const _GlassHeroSection({
    required this.totalAnswered,
    required this.accuracy,
    required this.streak,
  });

  final int totalAnswered;
  final int accuracy;
  final int streak;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: GlassContainer(
        width: double.infinity,
        blur: isDark ? 10 : 6,
        gradient: isDark
            ? ModernTheme.glassGradient
            : LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.02)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        child: Stack(
          children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ModernTheme.primary.withValues(alpha: 0.4),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ModernTheme.tertiary.withValues(alpha: 0.3),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'home.greeting'.tr(),
                        style: AppFonts.outfit(
                          context,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final shell = TabShellScope.maybeOf(context);
                        if (shell != null) {
                          shell.value = 4;
                        } else {
                          context.push('/settings');
                        }
                      },
                      icon: const Icon(PhosphorIconsRegular.gear),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBadge(
                        label: 'home.statLabels.streak'.tr(),
                        value: '$streak',
                        icon: Icons.local_fire_department_rounded,
                        iconColor: Colors.orangeAccent,
                      ),
                      _StatBadge(
                        label: 'home.statLabels.accuracy'.tr(),
                        value: '$accuracy%',
                        icon: Icons.analytics_rounded,
                        iconColor: ModernTheme.primary,
                      ),
                      _StatBadge(
                        label: 'home.statLabels.done'.tr(),
                        value: '$totalAnswered',
                        icon: Icons.check_circle_rounded,
                        iconColor: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppFonts.outfit(
                context,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 18,
                color: iconColor ??
                    Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.9),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.outfit(
            context,
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GlassActionCard extends StatelessWidget {
  const _GlassActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        AppFeedback.tap(context);
        onTap();
      },
      child: GlassContainer(
        height: 160,
        borderRadius: BorderRadius.circular(24),
        blur: isDark ? 10 : 6,
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.85),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.06),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -26,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.35 : 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.22 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: color.withValues(alpha: 0.35)),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsRegular.arrowUpRight,
                        size: 18,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: AppFonts.outfit(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.outfit(
                      context,
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassListTile extends StatelessWidget {
  const _GlassListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        AppFeedback.tap(context);
        onTap();
      },
      child: GlassContainer(
        height: 88,
        padding: EdgeInsetsDirectional.zero,
        borderRadius: BorderRadius.circular(20),
        blur: isDark ? 10 : 6,
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.08),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.65),
                      color.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -22,
              top: -26,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.22 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppFonts.outfit(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.outfit(
                            context,
                            fontSize: 12,
                            color:
                                scheme.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.caretRight,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
