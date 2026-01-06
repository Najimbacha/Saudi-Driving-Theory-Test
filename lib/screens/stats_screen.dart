import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../presentation/providers/category_provider.dart';
import '../presentation/providers/exam_history_provider.dart';
import '../state/app_state.dart';
import '../state/learning_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appSettingsProvider).stats;
    final learning = ref.watch(learningProvider);
    final categories = ref.watch(categoriesProvider);
    final history = ref.watch(examHistoryProvider);

    final totalAnswered = stats.totalAnswered;
    final accuracy = totalAnswered == 0
        ? 0
        : (stats.totalCorrect / totalAnswered * 100).round();
    final average = stats.quizzesTaken == 0
        ? 0
        : (stats.totalScore / stats.quizzesTaken).round();

    return Scaffold(
      appBar: AppBar(title: Text('stats.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (stats.quizzesTaken == 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('stats.noStats'.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('stats.noStatsDesc'.tr()),
                  ],
                ),
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
                _StatTile(label: 'results.accuracy'.tr(), value: '$average%'),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text('exam.topicBreakdown'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (learning.categoryStats.isEmpty)
            Text('common.empty'.tr(),
                style: Theme.of(context).textTheme.bodySmall)
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('history.title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () => context.push('/history'),
                child: Text('common.more'.tr()),
              ),
            ],
          ),
          if (history.isEmpty)
            Text('history.empty'.tr(),
                style: Theme.of(context).textTheme.bodySmall)
          else
            ...history.take(3).map(
                  (result) => Card(
                    child: ListTile(
                      title: Text(
                        '${'history.examTypes.${result.examType}'.tr()} • ${result.scorePercentage.toStringAsFixed(0)}%',
                      ),
                      subtitle: Text(
                          DateFormat.yMMMd().add_jm().format(result.dateTime)),
                      trailing: Icon(
                          result.passed ? Icons.check_circle : Icons.cancel,
                          color: result.passed
                              ? AppColors.success
                              : AppColors.error),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatStreak(BuildContext context, LearningState learning) {
    final current = learning.streak['current'] as int? ?? 0;
    return plural('stats.streakCount', current, args: [current.toString()]);
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
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.secondary.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('stats.title'.tr(),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('$accuracy%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                    )),
            const SizedBox(height: 6),
            Text('results.accuracy'.tr(),
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                backgroundColor: Theme.of(context).colorScheme.outline,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniStat(
                    label: 'quiz.question'.tr(),
                    value: totalAnswered.toString()),
                const SizedBox(width: 8),
                _MiniStat(label: 'stats.bestScore'.tr(), value: '$bestScore%'),
                const SizedBox(width: 8),
                _MiniStat(label: 'stats.streak'.tr(), value: streak),
              ],
            ),
          ],
        ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
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
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(item.value,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleSmall)),
            Text('$accuracy%'),
            const SizedBox(width: 12),
            Text('${total.toString()} ${'exam.questions'.tr()}'),
          ],
        ),
      ),
    );
  }
}
