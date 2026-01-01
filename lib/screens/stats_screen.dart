import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    final accuracy = totalAnswered == 0 ? 0 : (stats.totalCorrect / totalAnswered * 100).round();
    final average = stats.quizzesTaken == 0 ? 0 : (stats.totalScore / stats.quizzesTaken).round();

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
                    Text('stats.noStats'.tr(), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('stats.noStatsDesc'.tr()),
                  ],
                ),
              ),
            ),
          ] else ...[
            _StatGrid(
              items: [
                _StatTile(label: 'stats.quizzesTaken'.tr(), value: stats.quizzesTaken.toString()),
                _StatTile(label: 'stats.bestScore'.tr(), value: '${stats.bestScore}%'),
                _StatTile(label: 'stats.accuracy'.tr(), value: '$accuracy%'),
                _StatTile(label: 'stats.streak'.tr(), value: _formatStreak(context, learning)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('results.correct'.tr(), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(stats.totalCorrect.toString(), style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('quiz.question'.tr(), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(totalAnswered.toString(), style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('results.accuracy'.tr(), style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text('$average%', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('exam.topicBreakdown'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (learning.categoryStats.isEmpty)
            Text('common.empty'.tr(), style: Theme.of(context).textTheme.bodySmall)
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
                child: Text('history.title'.tr(), style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () => context.go('/history'),
                child: Text('common.more'.tr()),
              ),
            ],
          ),
          if (history.isEmpty)
            Text('history.empty'.tr(), style: Theme.of(context).textTheme.bodySmall)
          else
            ...history.take(3).map(
                  (result) => Card(
                    child: ListTile(
                      title: Text('${result.examType.toUpperCase()} • ${result.scorePercentage.toStringAsFixed(0)}%'),
                      subtitle: Text(DateFormat.yMMMd().add_jm().format(result.dateTime)),
                      trailing: Icon(result.passed ? Icons.check_circle : Icons.cancel,
                          color: result.passed ? AppColors.success : AppColors.error),
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
                Text(item.value, style: Theme.of(context).textTheme.titleMedium),
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
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
            Text('$accuracy%'),
            const SizedBox(width: 12),
            Text('${total.toString()} ${'exam.questions'.tr()}'),
          ],
        ),
      ),
    );
  }
}
