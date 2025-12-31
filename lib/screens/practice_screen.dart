import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/question.dart';
import '../state/app_state.dart';
import '../state/data_state.dart';
import '../state/learning_state.dart';
import '../widgets/bottom_nav.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String mode = 'all';
  String? selectedCategory;
  int current = 0;
  int? selected;
  bool showAnswer = false;
  int score = 0;
  List<Question> questions = [];
  List<String> wrongIds = [];
  List<Map<String, dynamic>> sessionResults = [];

  void startPractice(List<Question> pool) {
    if (pool.isEmpty) return;
    final shuffled = [...pool]..shuffle(Random());
    setState(() {
      questions = shuffled;
      current = 0;
      selected = null;
      showAnswer = false;
      score = 0;
      wrongIds = [];
      sessionResults = [];
    });
  }

  void handleSelect(int idx) {
    if (showAnswer) return;
    setState(() => selected = idx);
  }

  void handleSubmit() {
    if (selected == null) return;
    final q = questions[current];
    final correct = q.correctIndex;
    final isCorrect = selected == correct;
    if (isCorrect) {
      setState(() => score += 1);
    } else {
      if (!wrongIds.contains(q.id)) {
        setState(() => wrongIds.add(q.id));
      }
    }
    ref.read(learningProvider.notifier).recordAnswer(
          questionId: q.id,
          selectedAnswer: selected!,
          correctAnswer: correct,
          isCorrect: isCorrect,
          category: _categoryId(q),
          difficulty: _difficultyId(q),
        );
    setState(() {
      showAnswer = true;
      final entry = {'id': q.id, 'category': _categoryId(q), 'correct': isCorrect};
      sessionResults = [...sessionResults.where((e) => e['id'] != q.id), entry];
    });
  }

  void handleNext() {
    if (current < questions.length - 1) {
      setState(() {
        current += 1;
        selected = null;
        showAnswer = false;
      });
    } else {
      ref.read(appSettingsProvider.notifier).updateStats(correct: score, total: questions.length);
      setState(() => questions = []);
    }
  }

  String _categoryId(Question q) {
    final key = q.categoryKey;
    return key.split('.').last;
  }

  String _difficultyId(Question q) {
    final key = q.difficultyKey;
    return key.split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);
    final theme = Theme.of(context);

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('quiz.title'.tr()),
        ),
        body: questionsAsync.when(
          data: (data) {
            final categories = data.map(_categoryId).toSet().toList();
            final mistakes = ref.watch(learningProvider).mistakes;
            final mistakesIds = mistakes.map((m) => m.questionId).toSet();
            final mistakesPool = data.where((q) => mistakesIds.contains(q.id)).toList();
            final weakCategories = ref.read(learningProvider.notifier).getWeakCategories();
            final weakPool = data.where((q) => weakCategories.contains(_categoryId(q))).toList();
            final reviewIds = ref.read(learningProvider.notifier).getDueReviews();
            final reviewPool = data.where((q) => reviewIds.contains(q.id)).toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  TabBar(
                    tabs: [
                      Tab(text: 'practice.byMode'.tr()),
                      Tab(text: 'practice.byCategory'.tr()),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _modeCard(context, 'practice.modes.all', data.length.toString(), () {
                              mode = 'all';
                              selectedCategory = null;
                              startPractice(data);
                            }),
                            _modeCard(context, 'practice.modes.mistakes', mistakesPool.length.toString(), () {
                              mode = 'mistakes';
                              selectedCategory = null;
                              startPractice(mistakesPool);
                            }),
                            _modeCard(context, 'practice.modes.weak', weakPool.length.toString(), () {
                              mode = 'weak';
                              selectedCategory = null;
                              startPractice(weakPool);
                            }),
                            _modeCard(context, 'practice.modes.review', reviewPool.length.toString(), () {
                              mode = 'review';
                              selectedCategory = null;
                              startPractice(reviewPool);
                            }),
                            _modeCard(context, 'practice.modes.quick', min(10, data.length).toString(), () {
                              mode = 'quick';
                              selectedCategory = null;
                              startPractice(data.take(10).toList());
                            }),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: categories.map((cat) {
                            final pool = data.where((q) => _categoryId(q) == cat).toList();
                            return _modeCard(context, 'quiz.categories.$cat', pool.length.toString(), () {
                              mode = 'category';
                              selectedCategory = cat;
                              startPractice(pool);
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Failed to load')),
        ),
        bottomNavigationBar: const BottomNav(),
      );
    }

    final q = questions[current];
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
                      Text('quiz.title'.tr(), style: theme.textTheme.titleMedium),
                      Text('${current + 1} / ${questions.length}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Spacer(),
                  Text(mode, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            LinearProgressIndicator(value: (current + 1) / questions.length),
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
                            Row(
                              children: [
                                _chip(theme, q.categoryKey.tr()),
                                const SizedBox(width: 8),
                                _chip(theme, q.difficultyKey.tr()),
                              ],
                            ),
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
                            const SizedBox(height: 12),
                            Text(q.questionKey.tr(), style: theme.textTheme.titleMedium),
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
                          final isSelected = selected == idx;
                          final isCorrect = idx == q.correctIndex;
                          Color? bg;
                          Color? border;
                          if (showAnswer) {
                            if (isCorrect) {
                              bg = _withOpacity(theme.colorScheme.secondary, 0.4);
                              border = theme.colorScheme.primary;
                            } else if (isSelected) {
                              bg = _withOpacity(theme.colorScheme.error, 0.1);
                              border = theme.colorScheme.error;
                            }
                          } else if (isSelected) {
                            bg = _withOpacity(theme.colorScheme.primary, 0.1);
                            border = theme.colorScheme.primary;
                          }
                          return OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: bg,
                              side: BorderSide(color: border ?? theme.dividerColor),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            onPressed: () => handleSelect(idx),
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
                child: ElevatedButton(
                  onPressed: selected == null && !showAnswer ? null : (showAnswer ? handleNext : handleSubmit),
                  child: Text(showAnswer ? (current < questions.length - 1 ? 'quiz.next'.tr() : 'results.title'.tr()) : 'quiz.submit'.tr()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }

  Widget _modeCard(BuildContext context, String titleKey, String count, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(titleKey.tr()),
        subtitle: Text('quiz.selectQuestions'.tr()),
        trailing: Text(count),
        onTap: onTap,
      ),
    );
  }

  Color _withOpacity(Color color, double opacity) {
    return color.withAlpha((255 * opacity).round());
  }
}
