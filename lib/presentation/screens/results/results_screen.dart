import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../utils/text_formatters.dart';

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
          const SizedBox(height: 8),
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
              onPressed: () => context.go('/exam'),
              child: Text('exam.tryAgain'.tr()),
            ),
          ),
        ],
      ),
    );
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                passed ? 'results.passed'.tr() : 'results.failed'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: double.tryParse(score) ?? 0),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, _) {
              return Text(
                '${'results.score'.tr()}: ${value.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.displaySmall,
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            formatCorrectAnswers(context, correct, total),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

