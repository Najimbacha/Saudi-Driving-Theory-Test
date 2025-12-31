import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/question.dart';
import '../state/app_state.dart';
import '../state/data_state.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  String mode = 'standard';
  int currentIndex = 0;
  List<Question> questions = [];
  List<int?> answers = [];
  int timeLeft = 0;
  Timer? timer;

  void startExam(List<Question> pool, int minutes) {
    final shuffled = [...pool]..shuffle(Random());
    setState(() {
      questions = shuffled;
      answers = List<int?>.filled(shuffled.length, null);
      currentIndex = 0;
      timeLeft = minutes * 60;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 1) {
        t.cancel();
        setState(() => timeLeft = 0);
      } else {
        setState(() => timeLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);
    final theme = Theme.of(context);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('exam.title'.tr())),
        body: questionsAsync.when(
          data: (data) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _modeCard(context, 'exam.modes.real', 30, 30, () {
                  mode = 'real';
                  startExam(data.take(30).toList(), 30);
                }),
                _modeCard(context, 'exam.modes.quick', 10, 10, () {
                  mode = 'quick';
                  startExam(data.take(10).toList(), 10);
                }),
                _modeCard(context, 'exam.modes.standard', 20, 20, () {
                  mode = 'standard';
                  startExam(data.take(20).toList(), 20);
                }),
                _modeCard(context, 'exam.modes.full', 40, 40, () {
                  mode = 'full';
                  startExam(data.take(40).toList(), 40);
                }),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    mode = 'standard';
                    startExam(data.take(20).toList(), 20);
                  },
                  child: Text('exam.startExam'.tr()),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Failed to load')),
        ),
      );
    }

    final q = questions[currentIndex];
    final signMap = signsAsync.valueOrNull == null
        ? <String, String>{}
        : {for (final s in signsAsync.valueOrNull!) s.id: s.svgPath};
    final signPath = q.signId != null ? signMap[q.signId!] : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => questions = []),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('exam.title'.tr(), style: theme.textTheme.titleMedium),
                      Text('${currentIndex + 1} / ${questions.length}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Spacer(),
                  Text(_formatTime(timeLeft), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            LinearProgressIndicator(value: (currentIndex + 1) / questions.length),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.questionKey.tr(), style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            if (signPath != null)
                              Center(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      'assets/$signPath',
                                      height: 120,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: q.optionsKeys.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final isSelected = answers[currentIndex] == idx;
                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? _withOpacity(theme.colorScheme.primary, 0.1)
                                  : null,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            onPressed: () => setState(() => answers[currentIndex] = idx),
                            child: Text(q.optionsKeys[idx].tr()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: currentIndex == 0
                            ? null
                            : () => setState(() => currentIndex -= 1),
                        child: Text('common.previous'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentIndex < questions.length - 1) {
                            setState(() => currentIndex += 1);
                          } else {
                            final correct = answers.where((a) => a != null).where((a) {
                              final idx = answers.indexOf(a);
                              return a == questions[idx].correctIndex;
                            }).length;
                            ref.read(appSettingsProvider.notifier).updateStats(
                                  correct: correct,
                                  total: questions.length,
                                );
                            setState(() => questions = []);
                          }
                        },
                        child: Text(currentIndex < questions.length - 1 ? 'common.next'.tr() : 'exam.submit'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _modeCard(BuildContext context, String titleKey, int questions, int minutes, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(titleKey.tr()),
        subtitle: Text('exam.questionsCount'.tr(args: [questions.toString()])),
        trailing: Text('${minutes.toString()} ${'exam.minutes'.tr()}'),
        onTap: onTap,
      ),
    );
  }

  Color _withOpacity(Color color, double opacity) {
    return color.withAlpha((255 * opacity).round());
  }
}
