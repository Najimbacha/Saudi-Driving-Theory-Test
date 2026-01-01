import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/exam_history_provider.dart';

class ExamHistoryScreen extends ConsumerWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(examHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text('history.title'.tr())),
      body: history.isEmpty
          ? Center(child: Text('history.empty'.tr()))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final result = history[index];
                final score = result.scorePercentage.toStringAsFixed(0);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (result.passed
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.15),
                      child: Icon(
                        result.passed ? Icons.check_circle : Icons.cancel,
                        color:
                            result.passed ? AppColors.success : AppColors.error,
                      ),
                    ),
                    title: Text('${result.examType.toUpperCase()} • $score%'),
                    subtitle: Text(
                        DateFormat.yMMMd().add_jm().format(result.dateTime)),
                  ),
                );
              },
            ),
    );
  }
}
