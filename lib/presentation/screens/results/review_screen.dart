import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../models/question.dart';
import '../../../state/data_state.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key, required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('review.title'.tr())),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('common.error'.tr())),
        data: (questions) {
          final questionMap = {for (final q in questions) q.id: q};
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: result.questionAnswers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final answer = result.questionAnswers[index];
              final question = questionMap[answer.questionId];
              if (question == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('review.missingQuestion'.tr()),
                  ),
                );
              }
              return _ReviewCard(
                index: index + 1,
                question: question,
                answer: answer,
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.question,
    required this.answer,
  });

  final int index;
  final Question question;
  final QuestionAnswer answer;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final questionText = _questionText(question, locale);
    final options = _options(question, locale);
    final correct = answer.correctAnswerIndex;
    final selected = answer.userAnswerIndex;
    final isCorrect = answer.isCorrect;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isCorrect ? AppColors.success : AppColors.error).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$index',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Spacer(),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(questionText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(options.length, (idx) {
              final optionText = options[idx];
              final isSelected = idx == selected;
              final isCorrectOption = idx == correct;
              Color? border;
              Color? fill;
              if (isCorrectOption) {
                border = AppColors.success;
                fill = AppColors.success.withOpacity(0.12);
              } else if (isSelected && !isCorrectOption) {
                border = AppColors.error;
                fill = AppColors.error.withOpacity(0.12);
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: fill ?? Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border ?? Colors.transparent),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(optionText),
                  trailing: isCorrectOption
                      ? const Icon(Icons.check, color: AppColors.success)
                      : isSelected
                          ? const Icon(Icons.close, color: AppColors.error)
                          : null,
                ),
              );
            }),
            const SizedBox(height: 6),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('review.explanation'.tr()),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_explanation(question, locale)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _questionText(Question question, String locale) {
  if (locale == 'ar' && question.questionTextAr != null) {
    return question.questionTextAr!;
  }
  if (question.questionText != null) return question.questionText!;
  return question.questionKey.tr();
}

List<String> _options(Question question, String locale) {
  if (locale == 'ar' && question.optionsAr != null && question.optionsAr!.isNotEmpty) {
    return question.optionsAr!;
  }
  if (question.options != null && question.options!.isNotEmpty) {
    return question.options!;
  }
  return question.optionsKeys.map((key) => key.tr()).toList();
}

String _explanation(Question question, String locale) {
  if (locale == 'ar' && question.explanationAr != null) {
    return question.explanationAr!;
  }
  if (question.explanation != null) return question.explanation!;
  return question.explanationKey?.tr() ?? 'quiz.explanationFallback'.tr();
}
