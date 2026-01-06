import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/home_shell.dart';
import '../../../state/app_state.dart';
import '../../../state/learning_state.dart';

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
                            if (shell != null)
                              shell.value = 2;
                            else
                              context.push('/practice');
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
                            if (shell != null)
                              shell.value = 3;
                            else
                              context.push('/exam');
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
                        if (shell != null)
                          shell.value = 1;
                        else
                          context.push('/signs');
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
    return GlassContainer(
      height: 200,
      width: double.infinity,
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

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'home.greeting'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 28,
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
                const SizedBox(height: 4),
                Text(
                  'home.subtitle'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Row(
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
                    ),
                    _StatBadge(
                      label: 'home.statLabels.done'.tr(),
                      value: '$totalAnswered',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
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
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ],
          ],
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        height: 160,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  height: 1.2,
                ),
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
