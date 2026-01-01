import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../presentation/providers/exam_history_provider.dart';
import '../../../presentation/providers/exam_provider.dart';
import '../../../state/data_state.dart';

class ExamFlowScreen extends ConsumerStatefulWidget {
  const ExamFlowScreen({super.key});

  @override
  ConsumerState<ExamFlowScreen> createState() => _ExamFlowScreenState();
}

class _ExamFlowScreenState extends ConsumerState<ExamFlowScreen> {
  bool _handledCompletion = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final exam = ref.watch(examProvider);
    final controller = ref.read(examProvider.notifier);

    return questionsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text('exam.title'.tr())),
        body: Center(child: Text('common.error'.tr())),
      ),
      data: (questions) {
        if (exam.questions.isEmpty && _handledCompletion) {
          _handledCompletion = false;
        }
        if (exam.questions.isEmpty || exam.isCompleted) {
          if (exam.isCompleted && exam.questions.isNotEmpty) {
            if (!_handledCompletion) {
              _handledCompletion = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _finishExam(context, ref, exam);
                controller.reset();
              });
            }
            return const SizedBox.shrink();
          }
          return _ExamIntro(onStart: () => controller.start(questions.take(30).toList(), minutes: 30));
        }
        final current = exam.currentQuestion;
        final selected = exam.answers[current.id];
        return Scaffold(
          appBar: AppBar(
            title: Text('exam.title'.tr()),
            actions: [
              IconButton(
                onPressed: controller.toggleFlag,
                icon: Icon(
                  exam.flagged.contains(current.id) ? Icons.flag : Icons.outlined_flag,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimerBanner(timeLeftSeconds: exam.timeLeftSeconds),
                const SizedBox(height: 12),
                Text('exam.progressCount'.tr(args: [(exam.currentIndex + 1).toString(), exam.questions.length.toString()])),
                const SizedBox(height: 12),
                Text(current.questionKey.tr(), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...List.generate(current.optionsKeys.length, (idx) {
                  final optionKey = current.optionsKeys[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected == idx ? AppColors.accent : Colors.transparent,
                      ),
                      color: selected == idx ? AppColors.accent.withOpacity(0.12) : Theme.of(context).cardColor,
                    ),
                    child: ListTile(
                      title: Text(optionKey.tr()),
                      onTap: () => controller.selectAnswer(idx),
                    ),
                  );
                }),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: exam.currentIndex == 0 ? null : controller.previous,
                        child: Text('common.previous'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (exam.currentIndex + 1 == exam.questions.length) {
                            controller.finish();
                          } else {
                            controller.next();
                          }
                        },
                        child: Text(exam.currentIndex + 1 == exam.questions.length ? 'exam.submit'.tr() : 'common.next'.tr()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showQuestionGrid(context, exam, controller),
                  child: Text('exam.reviewAnswers'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _finishExam(BuildContext context, WidgetRef ref, ExamState exam) {
    final total = exam.questions.length;
    final correct = exam.answers.entries
        .where((e) => exam.questions.firstWhere((q) => q.id == e.key).correctIndex == e.value)
        .length;
    final wrong = exam.answers.length - correct;
    final skipped = total - exam.answers.length;
    final result = ExamResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      examType: 'exam',
      totalQuestions: total,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      scorePercentage: total == 0 ? 0 : (correct / total) * 100,
      passed: total == 0 ? false : correct / total >= 0.7,
      timeTakenSeconds: DateTime.now().difference(exam.startedAt).inSeconds,
      categoryScores: _categoryScores(exam),
      questionAnswers: exam.answers.entries
          .map((e) => QuestionAnswer(
                questionId: e.key,
                userAnswerIndex: e.value,
                correctAnswerIndex: exam.questions.firstWhere((q) => q.id == e.key).correctIndex,
              ))
          .toList(),
    );
    ref.read(examHistoryProvider.notifier).addResult(result);
    context.push('/results', extra: result);
  }

  static Map<String, int> _categoryScores(ExamState exam) {
    final scores = <String, int>{};
    for (final entry in exam.answers.entries) {
      final question = exam.questions.firstWhere((q) => q.id == entry.key);
      final category = _categoryId(question.categoryKey);
      if (entry.value == question.correctIndex) {
        scores[category] = (scores[category] ?? 0) + 1;
      }
    }
    return scores;
  }

  static String _categoryId(String categoryKey) {
    final parts = categoryKey.split('.');
    return parts.isNotEmpty ? parts.last : categoryKey;
  }

  void _showQuestionGrid(BuildContext context, ExamState exam, ExamController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: exam.questions.length,
          itemBuilder: (context, index) {
            final question = exam.questions[index];
            final answered = exam.answers.containsKey(question.id);
            final flagged = exam.flagged.contains(question.id);
            Color color = Theme.of(context).cardColor;
            if (flagged) color = AppColors.secondary.withOpacity(0.4);
            if (answered) color = AppColors.success.withOpacity(0.3);
            return InkWell(
              onTap: () {
                controller.goTo(index);
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${index + 1}'),
              ),
            );
          },
        );
      },
    );
  }
}

class _ExamIntro extends StatelessWidget {
  const _ExamIntro({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('exam.title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('exam.description'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            _InfoRow(label: 'exam.duration'.tr(), value: '30 ${'exam.minutes'.tr()}'),
            _InfoRow(label: 'exam.questions'.tr(), value: '30'),
            _InfoRow(label: 'exam.passingScore'.tr(), value: '70%'),
            const SizedBox(height: 16),
            Text('exam.disclaimer'.tr(), style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                child: Text('exam.startExam'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TimerBanner extends StatelessWidget {
  const _TimerBanner({required this.timeLeftSeconds});

  final int timeLeftSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (timeLeftSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeLeftSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
