import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/modern_theme.dart';
import '../presentation/providers/category_provider.dart';
import '../presentation/providers/exam_history_provider.dart';
import '../state/app_state.dart';
import '../state/learning_state.dart';
import '../utils/app_fonts.dart';
import '../widgets/glass_container.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appSettingsProvider).stats;
    final learning = ref.watch(learningProvider);
    final categories = ref.watch(categoriesProvider);
    final history = ref.watch(examHistoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalAnswered = stats.totalAnswered;
    final accuracy = totalAnswered == 0
        ? 0
        : (stats.totalCorrect / totalAnswered * 100).round();
    final average = stats.quizzesTaken == 0
        ? 0
        : (stats.totalScore / stats.quizzesTaken).round();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'stats.title'.tr(),
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            cacheExtent: 800,
            children: [
              if (stats.quizzesTaken == 0) ...[
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  blur: isDark ? 12 : 6,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.9),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'stats.noStats'.tr(),
                        style: AppFonts.outfit(
                          context,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'stats.noStatsDesc'.tr(),
                        style: AppFonts.outfit(
                          context,
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _SummaryHero(
                  accuracy: accuracy,
                  totalAnswered: totalAnswered,
                  bestScore: stats.bestScore,
                  streak: _formatStreak(context, learning),
                ),
                const SizedBox(height: 16),
                _StatGrid(
                  items: [
                    _StatTile(
                        label: 'stats.quizzesTaken'.tr(),
                        value: stats.quizzesTaken.toString()),
                    _StatTile(
                        label: 'results.correct'.tr(),
                        value: stats.totalCorrect.toString()),
                    _StatTile(
                        label: 'quiz.question'.tr(),
                        value: totalAnswered.toString()),
                    _StatTile(
                        label: 'results.accuracy'.tr(), value: '$average%'),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'exam.topicBreakdown'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (learning.categoryStats.isEmpty)
                Text(
                  'common.empty'.tr(),
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else
                ...categories.map((cat) {
                  final stat = learning.categoryStats[cat.id];
                  if (stat == null) return const SizedBox.shrink();
                  return _CategoryStatTile(
                    title: cat.titleKey.tr(),
                    accuracy: stat.accuracy,
                    total: stat.total,
                  );
                }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'history.title'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: Text(
                      'common.more'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: ModernTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (history.isEmpty)
                Text(
                  'history.empty'.tr(),
                  style: AppFonts.outfit(
                    context,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else
                ...history.take(3).map((result) {
                  final title =
                      '${'history.examTypes.${result.examType}'.tr()} • ${result.scorePercentage.toStringAsFixed(0)}%';
                  final subtitle =
                      DateFormat.yMMMd().add_jm().format(result.dateTime);
                  return _HistoryTile(
                    title: title,
                    subtitle: subtitle,
                    passed: result.passed,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStreak(BuildContext context, LearningState learning) {
    final current = learning.streak['current'] as int? ?? 0;
    return plural(
      'stats.streakCount',
      current,
      namedArgs: {'value': current.toString()},
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.accuracy,
    required this.totalAnswered,
    required this.bestScore,
    required this.streak,
  });

  final int accuracy;
  final int totalAnswered;
  final int bestScore;
  final String streak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracyColor = _accuracyColor(accuracy);

    return GlassContainer(
      padding: EdgeInsets.zero,
      blur: isDark ? 12 : 8,
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.9),
      border: Border.all(color: scheme.onSurface.withValues(alpha: 0.1)),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ModernTheme.primary.withValues(alpha: 0.3),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ModernTheme.secondary.withValues(alpha: 0.25),
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
                Text(
                  'stats.title'.tr(),
                  style: AppFonts.outfit(
                    context,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$accuracy%',
                      style: AppFonts.outfit(
                        context,
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        color: accuracyColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'results.accuracy'.tr(),
                        style: AppFonts.outfit(
                          context,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: accuracy / 100,
                    backgroundColor:
                        scheme.onSurface.withValues(alpha: 0.12),
                    color: accuracyColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MiniStat(
                        label: 'quiz.question'.tr(),
                        value: totalAnswered.toString()),
                    const SizedBox(width: 12),
                    _MiniStat(
                        label: 'stats.bestScore'.tr(),
                        value: '$bestScore%'),
                    const SizedBox(width: 12),
                    _MiniStat(label: 'stats.streak'.tr(), value: streak),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.outfit(
                context,
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.outfit(
                context,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.items});

  final List<_StatTile> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          blur: isDark ? 10 : 6,
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.outfit(
                  context,
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.value,
                style: AppFonts.outfit(
                  context,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatTile {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;
}

class _CategoryStatTile extends StatelessWidget {
  const _CategoryStatTile({
    required this.title,
    required this.accuracy,
    required this.total,
  });

  final String title;
  final int accuracy;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracyColor = _accuracyColor(accuracy);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      blur: isDark ? 10 : 6,
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.9),
      border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${total.toString()} ${'exam.questions'.tr()}',
                  style: AppFonts.outfit(
                    context,
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accuracyColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$accuracy%',
              style: AppFonts.outfit(
                context,
                fontWeight: FontWeight.bold,
                color: accuracyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.passed,
  });

  final String title;
  final String subtitle;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = passed ? AppColors.success : AppColors.error;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      blur: isDark ? 10 : 6,
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.9),
      border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              passed ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _accuracyColor(int accuracy) {
  if (accuracy >= 80) {
    return AppColors.success;
  }
  if (accuracy >= 50) {
    return ModernTheme.primary;
  }
  return AppColors.warning;
}
