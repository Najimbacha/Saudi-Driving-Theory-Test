import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/home_shell.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../data/models/category_model.dart';
import '../../../models/question.dart';
import '../../../presentation/providers/exam_history_provider.dart';
import '../../../presentation/providers/quiz_provider.dart';
import '../../../state/data_state.dart';
import '../../../state/app_state.dart';
import '../../providers/category_provider.dart';

class PracticeFlowScreen extends ConsumerStatefulWidget {
  const PracticeFlowScreen({super.key});

  @override
  ConsumerState<PracticeFlowScreen> createState() => _PracticeFlowScreenState();
}

class _PracticeFlowScreenState extends ConsumerState<PracticeFlowScreen> {
  bool _handledCompletion = false;
  bool _initialCategoryHandled = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);
    final quiz = ref.watch(quizProvider);
    final quizController = ref.read(quizProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final favorites = ref.watch(appSettingsProvider).favorites;
    final categoryParam =
        GoRouterState.of(context).uri.queryParameters['category'];

    return questionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text('quiz.title'.tr())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'common.error'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'common.questionsLoadError'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // ROOT FIX: Retry by invalidating the provider
                    ref.invalidate(questionsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('common.retry'.tr()),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(
                    'common.technicalDetails'.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'common.questionsLoadErrorDetails'.tr(
                          namedArgs: {'error': error.toString()},
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      data: (questions) {
        if (quiz.questions.isEmpty && _handledCompletion) {
          _handledCompletion = false;
        }
        if (quiz.questions.isEmpty) {
          // ... (Logic for category selection remains mostly same, just styled)
          if (categoryParam != null && !_initialCategoryHandled) {
            _initialCategoryHandled = true;
            final filtered = _filterByCategory(questions, categoryParam);
            final availableCategories = categories
                .where((cat) => _filterByCategory(questions, cat.id).isNotEmpty)
                .toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              if (filtered.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('categories.empty'.tr()),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
            });
            if (filtered.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                quizController.start(filtered);
              });
              return const SizedBox.shrink();
            }
            return _PracticeSelector(
              categories: availableCategories,
              questions: questions,
              onStart: (categoryId) {
                final nextFiltered = _filterByCategory(questions, categoryId);
                if (nextFiltered.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('categories.empty'.tr()),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                  return;
                }
                quizController.start(nextFiltered);
              },
            );
          }
          final availableCategories = categories
              .where((cat) => _filterByCategory(questions, cat.id).isNotEmpty)
              .toList();
          return _PracticeSelector(
            categories: availableCategories,
            questions: questions,
            onStart: (categoryId) {
              final filtered = _filterByCategory(questions, categoryId);
              if (filtered.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('categories.empty'.tr()),
                    backgroundColor: AppColors.secondary,
                  ),
                );
                return;
              }
              quizController.start(filtered);
            },
          );
        }

        if (quiz.isCompleted) {
          if (!_handledCompletion) {
            _handledCompletion = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _finishPractice(context, ref, quiz);
              quizController.reset();
            });
          }
          return const SizedBox.shrink();
        }

        final current = quiz.currentQuestion;
        final signMap = signsAsync.valueOrNull == null
            ? <String, String>{}
            : {for (final s in signsAsync.valueOrNull!) s.id: s.svgPath};
        final signPath =
            current.signId != null ? signMap[current.signId!] : null;
        final locale = context.locale.languageCode;
        final selected = quiz.selectedAnswers[current.id];
        final isCorrect = selected != null && selected == current.correctIndex;
        final questionText = _questionText(current, locale);
        final options = _options(current, locale);
        final isActiveQuiz = quiz.questions.isNotEmpty && !quiz.isCompleted;
        final canSkip = selected == null && !quiz.showAnswer;
        final canPressNext = selected != null;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryTextColor = scheme.onSurface;
        final secondaryTextColor = scheme.onSurface.withValues(alpha: 0.7);
        final defaultFill = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : scheme.onSurface.withValues(alpha: 0.04);
        final subtleFill = isDark
            ? Colors.white.withValues(alpha: 0.04)
            : scheme.onSurface.withValues(alpha: 0.03);
        final defaultBorder =
            isDark ? Colors.white10 : scheme.onSurface.withValues(alpha: 0.12);
        Future<void> handleBack() async {
          final shell = TabShellScope.maybeOf(context);
          if (isActiveQuiz) {
            quizController.reset();
          }
          final didPop = await Navigator.of(context).maybePop();
          if (!didPop && shell != null) {
            shell.value = 0;
          }
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) {
              if (isActiveQuiz) {
                quizController.reset();
              }
              return;
            }
            final shell = TabShellScope.maybeOf(context);
            if (isActiveQuiz) {
              quizController.reset();
            }
            if (shell != null) {
              shell.value = 0;
            } else {
              if (context.mounted) Navigator.of(context).maybePop();
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: primaryTextColor),
              leading: IconButton(
                onPressed: handleBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                'quiz.title'.tr(),
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              centerTitle: true,
              actions: [
                _BookmarkButton(
                  isBookmarked: favorites.questions.contains(current.id),
                  count: favorites.questions.length,
                  onTap: () {
                    final settings = ref.read(appSettingsProvider);
                    if (settings.vibrationEnabled) HapticFeedback.lightImpact();
                    if (settings.soundEnabled)
                      SystemSound.play(SystemSoundType.click);
                    ref.read(appSettingsProvider.notifier).toggleFavorite(
                          type: 'questions',
                          id: current.id,
                        );
                  },
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? ModernTheme.darkGradient
                    : ModernTheme.lightGradient,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Progress Header
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${'quiz.question'.tr()} ${quiz.currentIndex + 1}/${quiz.questions.length}',
                                style: GoogleFonts.outfit(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                current.categoryKey.tr(),
                                style: GoogleFonts.outfit(
                                  color: ModernTheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (quiz.currentIndex + 1) /
                                  quiz.questions.length,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : scheme.onSurface.withValues(alpha: 0.1),
                              color: ModernTheme.primary,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          // Question Text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              questionText,
                              key: ValueKey(current.id),
                              style: GoogleFonts.outfit(
                                fontSize: 22, // Larger text
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sign Image
                          if (signPath != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(20),
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : scheme.onSurface.withValues(alpha: 0.04),
                                child: SvgPicture.asset(
                                  'assets/$signPath',
                                  height: 140,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Visibility(
                              visible: canSkip,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      scheme.onSurface.withValues(alpha: 0.7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                onPressed: canSkip
                                    ? () {
                                        final settings =
                                            ref.read(appSettingsProvider);
                                        if (settings.vibrationEnabled)
                                          HapticFeedback.lightImpact();
                                        if (settings.soundEnabled)
                                          SystemSound.play(
                                              SystemSoundType.click);
                                        quizController.skipCurrent();
                                        quizController.next();
                                      }
                                    : null,
                                child: Text('common.skip'.tr(),
                                    style: GoogleFonts.outfit(fontSize: 13)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Options
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey('${current.id}-options'),
                              children: List.generate(options.length, (idx) {
                                final optionText = options[idx];
                                final wasSelected = selected == idx;
                                Color borderColor = defaultBorder;
                                Color? fillColor;
                                List<BoxShadow> shadow = const [];

                                if (quiz.showAnswer) {
                                  if (idx == current.correctIndex) {
                                    fillColor = AppColors.success
                                        .withValues(alpha: 0.18);
                                    borderColor = AppColors.success;
                                    shadow = [
                                      BoxShadow(
                                        color: AppColors.success
                                            .withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ];
                                  } else if (wasSelected) {
                                    fillColor =
                                        AppColors.error.withValues(alpha: 0.18);
                                    borderColor = AppColors.error;
                                    shadow = [
                                      BoxShadow(
                                        color: AppColors.error
                                            .withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ];
                                  } else {
                                    fillColor = subtleFill;
                                    borderColor = defaultBorder;
                                  }
                                } else {
                                  fillColor = defaultFill;
                                  borderColor = defaultBorder;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (quiz.showAnswer) return;
                                      final settings =
                                          ref.read(appSettingsProvider);
                                      if (settings.vibrationEnabled)
                                        HapticFeedback.lightImpact();
                                      if (settings.soundEnabled)
                                        SystemSound.play(SystemSoundType.click);
                                      quizController.selectAnswer(idx);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: fillColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: borderColor,
                                          width: (borderColor !=
                                                  Colors.transparent)
                                              ? 2
                                              : 1,
                                        ),
                                        boxShadow: shadow,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          _OptionBadge(
                                            label:
                                                String.fromCharCode(65 + idx),
                                            active: wasSelected,
                                            success: quiz.showAnswer &&
                                                idx == current.correctIndex,
                                            error: quiz.showAnswer &&
                                                wasSelected &&
                                                idx != current.correctIndex,
                                            isDark: isDark,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              optionText,
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ),
                                          if (quiz.showAnswer &&
                                              idx == current.correctIndex)
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.success),
                                          if (quiz.showAnswer &&
                                              wasSelected &&
                                              idx != current.correctIndex)
                                            const Icon(Icons.cancel_rounded,
                                                color: AppColors.error),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          // Explanation
                          if (quiz.showAnswer) ...[
                            const SizedBox(height: 16),
                            GlassContainer(
                              color: (isCorrect
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withValues(alpha: 0.1),
                              border: Border.all(
                                  color: (isCorrect
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.3)),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCorrect
                                        ? 'quiz.correct'.tr()
                                        : 'quiz.incorrect'.tr(),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _explanation(current, locale),
                                    style: GoogleFonts.outfit(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    GlassContainer(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.8),
                      blur: 10,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.24)),
                                foregroundColor: primaryTextColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                // Logic remains same
                                if (quiz.questions.isNotEmpty &&
                                    !quiz.isCompleted) {
                                  // ... Confirm exit logic
                                  showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: isDark
                                          ? const Color(0xFF1E293B)
                                          : scheme.surface,
                                      title: Text('practice.exitTitle'.tr(),
                                          style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              color: primaryTextColor)),
                                      content: Text('practice.exitMessage'.tr(),
                                          style: GoogleFonts.outfit(
                                              color: secondaryTextColor)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('common.cancel'.tr(),
                                                style: GoogleFonts.outfit(
                                                    color: scheme.onSurface
                                                        .withValues(
                                                            alpha: 0.6)))),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text('practice.exitConfirm'.tr(),
                                                style: GoogleFonts.outfit(
                                                    color: ModernTheme
                                                        .secondary))),
                                      ],
                                    ),
                                  ).then((shouldExit) {
                                    if (shouldExit == true && context.mounted) {
                                      quizController.reset();
                                      final shell =
                                          TabShellScope.maybeOf(context);
                                      if (shell != null) {
                                        shell.value = 0;
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  });
                                } else {
                                  final shell = TabShellScope.maybeOf(context);
                                  if (shell != null) {
                                    shell.value = 0;
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: Text('common.cancel'.tr(),
                                  style: GoogleFonts.outfit()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ModernTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 8,
                                shadowColor:
                                    ModernTheme.primary.withValues(alpha: 0.5),
                              ).copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.disabled))
                                    return ModernTheme.primary
                                        .withOpacity(0.45);
                                  return ModernTheme.primary;
                                }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.disabled))
                                    return Colors.white60;
                                  return Colors.white;
                                }),
                              ),
                              onPressed: canPressNext
                                  ? () {
                                      if (selected == null) {
                                        return;
                                      }
                                      final settings =
                                          ref.read(appSettingsProvider);
                                      if (settings.vibrationEnabled)
                                        HapticFeedback.lightImpact();
                                      if (settings.soundEnabled)
                                        SystemSound.play(SystemSoundType.click);
                                      if (!quiz.showAnswer) {
                                        quizController.revealAnswer();
                                      } else {
                                        quizController.next();
                                      }
                                    }
                                  : null,
                              child: Text(
                                quiz.currentIndex + 1 == quiz.questions.length
                                    ? 'quiz.submit'.tr()
                                    : 'common.next'.tr(),
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ... (Helper methods for finish, scoring, filtering - implementation remains same but hidden for brevity if not changed, but I will include them to avoid compilation errors)
  void _finishPractice(BuildContext context, WidgetRef ref, QuizState quiz) {
    // ... Copy exact logic from original file
    final total = quiz.questions.length;
    final correct = quiz.correctCount;
    final skipped = quiz.skippedQuestions.length;
    final wrong = total - correct - skipped;
    final result = ExamResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      examType: 'practice',
      totalQuestions: total,
      correctAnswers: correct,
      wrongAnswers: wrong,
      skippedAnswers: skipped,
      scorePercentage: total == 0 ? 0 : (correct / total) * 100,
      passed: total == 0 ? false : correct / total >= 0.7,
      timeTakenSeconds: DateTime.now().difference(quiz.startedAt).inSeconds,
      categoryScores: _categoryScores(quiz),
      questionAnswers: quiz.questions
          .map((q) => QuestionAnswer(
                questionId: q.id,
                userAnswerIndex: quiz.selectedAnswers[q.id] ?? -1,
                correctAnswerIndex: q.correctIndex,
              ))
          .toList(),
    );
    ref.read(examHistoryProvider.notifier).addResult(result);
  }

  static Map<String, int> _categoryScores(QuizState quiz) {
    final scores = <String, int>{};
    for (final entry in quiz.selectedAnswers.entries) {
      final question = quiz.questions.firstWhere((q) => q.id == entry.key);
      final category = question.categoryId;
      if (entry.value == question.correctIndex) {
        scores[category] = (scores[category] ?? 0) + 1;
      }
    }
    return scores;
  }

  static List<Question> _filterByCategory(
      List<Question> questions, String categoryId) {
    if (categoryId == 'all') return questions;
    return questions.where((q) => q.categoryId == categoryId).toList();
  }
}

// ... (Helper functions for _questionText, _options, _explanation - Keep exact same logic)
String _questionText(Question question, String locale) {
  switch (locale) {
    case 'ar':
      if (question.questionTextAr != null) return question.questionTextAr!;
      break;
    case 'ur':
      if (question.questionTextUr != null) return question.questionTextUr!;
      break;
    case 'hi':
      if (question.questionTextHi != null) return question.questionTextHi!;
      break;
    case 'bn':
      if (question.questionTextBn != null) return question.questionTextBn!;
      break;
  }
  if (question.questionText != null) return question.questionText!;
  return question.questionKey.tr();
}

List<String> _options(Question question, String locale) {
  List<String>? localeOptions;
  switch (locale) {
    case 'ar':
      localeOptions = question.optionsAr;
      break;
    case 'ur':
      localeOptions = question.optionsUr;
      break;
    case 'hi':
      localeOptions = question.optionsHi;
      break;
    case 'bn':
      localeOptions = question.optionsBn;
      break;
  }
  if (localeOptions != null && localeOptions.isNotEmpty) return localeOptions;
  if (question.options != null && question.options!.isNotEmpty)
    return question.options!;
  return question.optionsKeys.map((key) => key.tr()).toList();
}

String _explanation(Question question, String locale) {
  switch (locale) {
    case 'ar':
      if (question.explanationAr != null) return question.explanationAr!;
      break;
    case 'ur':
      if (question.explanationUr != null) return question.explanationUr!;
      break;
    case 'hi':
      if (question.explanationHi != null) return question.explanationHi!;
      break;
    case 'bn':
      if (question.explanationBn != null) return question.explanationBn!;
      break;
  }
  if (question.explanation != null) return question.explanation!;
  return question.explanationKey?.tr() ?? 'quiz.explanationFallback'.tr();
}

// ... (_PracticeSelector rewritten with Glass)
class _PracticeSelector extends StatefulWidget {
  const _PracticeSelector({
    required this.categories,
    required this.questions,
    required this.onStart,
  });

  final List<CategoryModel> categories;
  final List<Question> questions;
  final void Function(String categoryId) onStart;

  @override
  State<_PracticeSelector> createState() => _PracticeSelectorState();
}

class _PracticeSelectorState extends State<_PracticeSelector> {
  String _selectedId = 'all';

  static IconData _iconForCategoryId(String id) {
    switch (id) {
      case 'all':
        return PhosphorIconsRegular.gridFour;
      case 'signs':
        return PhosphorIconsRegular.trafficSign;
      case 'rules':
        return PhosphorIconsRegular.gavel;
      case 'safety':
        return PhosphorIconsRegular.shieldCheck;
      case 'signals':
        return PhosphorIconsRegular.trafficSignal;
      case 'markings':
        return PhosphorIconsRegular.roadHorizon;
      case 'parking':
        return PhosphorIconsRegular.carSimple;
      case 'emergency':
        return PhosphorIconsRegular.warning;
      case 'pedestrians':
        return PhosphorIconsRegular.personSimpleWalk;
      case 'highway':
        return PhosphorIconsRegular.roadHorizon;
      case 'weather':
        return PhosphorIconsRegular.sunDim;
      case 'maintenance':
        return PhosphorIconsRegular.wrench;
      case 'responsibilities':
        return PhosphorIconsRegular.identificationBadge;
      case 'violation_points':
        return PhosphorIconsRegular.warningDiamond;
      case 'traffic_fines':
        return PhosphorIconsRegular.fileText;
      default:
        return PhosphorIconsRegular.signpost;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = _buildCounts(widget.questions, widget.categories);
    final selectedLabel = _selectedId == 'all'
        ? 'quiz.categories.all'.tr()
        : widget.categories
            .firstWhere((c) => c.id == _selectedId,
                orElse: () => widget.categories.first)
            .titleKey
            .tr();
    final selectedCount = counts[_selectedId] ?? counts['all'] ?? 0;
    final minutes = ((selectedCount * 25) / 60).ceil();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final shell = TabShellScope.maybeOf(context);
        if (shell != null) {
          shell.value = 0;
          return;
        }
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('quiz.selectCategory'.tr(),
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, color: scheme.onSurface)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: scheme.onSurface),
          leading: IconButton(
            onPressed: () {
              final shell = TabShellScope.maybeOf(context);
              if (shell != null) {
                shell.value = 0;
                return;
              }
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient:
                isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Hero Selection Card
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(26),
                    gradient: ModernTheme.primaryGradient,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : scheme.onSurface.withValues(alpha: 0.04),
                    border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : scheme.onSurface.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(28),
                    blur: 12,
                    child: Column(
                      children: [
                        Text(
                          selectedLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatPill(
                                icon: PhosphorIconsRegular.question,
                                label: 'categories.totalQuestions'.tr(
                                  namedArgs: {
                                    'value': selectedCount.toString()
                                  },
                                )),
                            const SizedBox(width: 8),
                            _StatPill(
                                icon: PhosphorIconsRegular.timer,
                                label: 'quiz.estimatedTime'.tr(
                                  namedArgs: {'minutes': minutes.toString()},
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _CategoryGlassTile(
                          label: 'quiz.categories.all'.tr(),
                          selected: _selectedId == 'all',
                          icon: _iconForCategoryId('all'),
                          onTap: () => setState(() => _selectedId = 'all'),
                          width: (MediaQuery.of(context).size.width - 52) / 2,
                        ),
                        ...widget.categories.map((cat) => _CategoryGlassTile(
                              label: cat.titleKey.tr(),
                              selected: _selectedId == cat.id,
                              icon: _iconForCategoryId(cat.id),
                              onTap: () => setState(() => _selectedId = cat.id),
                              width:
                                  (MediaQuery.of(context).size.width - 52) / 2,
                            )),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        shadowColor:
                            ModernTheme.secondary.withValues(alpha: 0.35),
                      ),
                      onPressed: () => widget.onStart(_selectedId),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernTheme.secondary.withValues(alpha: 0.95),
                              ModernTheme.secondary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ModernTheme.secondary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          alignment: Alignment.center,
                          child: Text(
                            'quiz.start'.tr(),
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGlassTile extends StatelessWidget {
  const _CategoryGlassTile({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
    required this.width,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = selected
        ? ModernTheme.secondary
        : scheme.onSurface.withValues(alpha: isDark ? 0.55 : 0.65);
    return GestureDetector(
      onTap: () {
        final settings =
            ProviderScope.containerOf(context).read(appSettingsProvider);
        if (settings.vibrationEnabled) HapticFeedback.lightImpact();
        if (settings.soundEnabled) SystemSound.play(SystemSoundType.click);
        onTap();
      },
      child: AnimatedScale(
        scale: selected ? 1.02 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: width,
          height: 120,
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : scheme.onSurface.withValues(alpha: 0.06))
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : scheme.onSurface.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? ModernTheme.secondary.withValues(alpha: 0.45)
                  : scheme.onSurface.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ModernTheme.secondary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 45, color: iconColor),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: scheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0.3,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    PhosphorIconsRegular.checkCircle,
                    color: ModernTheme.secondary,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurface.withValues(alpha: 0.7), size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.outfit(color: scheme.onSurface, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.isBookmarked,
    required this.count,
    required this.onTap,
  });

  final bool isBookmarked;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        foregroundColor: isBookmarked
            ? ModernTheme.secondary
            : scheme.onSurface.withValues(alpha: 0.7),
      ),
      icon: Icon(isBookmarked
          ? Icons.bookmark_rounded
          : Icons.bookmark_border_rounded),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  const _OptionBadge({
    required this.label,
    required this.active,
    required this.success,
    required this.error,
    required this.isDark,
  });

  final String label;
  final bool active;
  final bool success;
  final bool error;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color bg = isDark ? Colors.white10 : Colors.black.withOpacity(0.06);
    Color border = isDark ? Colors.white24 : Colors.black12;

    if (active) {
      bg = ModernTheme.secondary;
      border = ModernTheme.secondary;
    }
    if (success) {
      bg = AppColors.success;
      border = AppColors.success;
    }
    if (error) {
      bg = AppColors.error;
      border = AppColors.error;
    }

    final text = bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Map<String, int> _buildCounts(
  List<Question> questions,
  List<CategoryModel> categories,
) {
  final counts = <String, int>{'all': questions.length};
  for (final category in categories) {
    counts[category.id] = 0;
  }
  for (final question in questions) {
    counts[question.categoryId] = (counts[question.categoryId] ?? 0) + 1;
  }
  return counts;
}
