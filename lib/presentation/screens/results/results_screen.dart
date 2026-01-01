import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_result_model.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final accuracy = result.scorePercentage.toStringAsFixed(0);
    return Scaffold(
      appBar: AppBar(title: Text('results.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeroScore(
            score: accuracy,
            passed: passed,
            total: result.totalQuestions,
            correct: result.correctAnswers,
          ),
          const SizedBox(height: 16),
          _StatsRow(
            items: [
              _StatItem(
                  label: 'results.correct'.tr(),
                  value: result.correctAnswers.toString()),
              _StatItem(
                  label: 'results.incorrect'.tr(),
                  value: result.wrongAnswers.toString()),
              _StatItem(label: 'results.accuracy'.tr(), value: '$accuracy%'),
              _StatItem(
                  label: 'results.time'.tr(),
                  value: _formatSeconds(result.timeTakenSeconds)),
            ],
          ),
          const SizedBox(height: 20),
          Text('exam.topicBreakdown'.tr(),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...result.categoryScores.entries.map(
            (entry) => ListTile(
              title: Text('categories.${entry.key}.title'.tr()),
              trailing: Text(entry.value.toString()),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: Text('results.backHome'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/review', extra: result),
                  child: Text('results.reviewAnswers'.tr()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/practice'),
              child: Text('results.tryAgain'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remain = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remain';
  }
}

class _HeroScore extends StatelessWidget {
  const _HeroScore({
    required this.score,
    required this.passed,
    required this.total,
    required this.correct,
  });

  final String score;
  final bool passed;
  final int total;
  final int correct;

  @override
  Widget build(BuildContext context) {
    final color = passed ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            passed ? 'results.passed'.tr() : 'results.failed'.tr(),
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(
            '${'results.score'.tr()}: $score%',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'exam.scoreSummary'
                .tr(args: [correct.toString(), total.toString()]),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatItem> items;

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
            padding: const EdgeInsets.all(12),
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

class _StatItem {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;
}
