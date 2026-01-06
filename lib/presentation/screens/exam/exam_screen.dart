import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/home_shell.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../models/question.dart';
import '../../../presentation/providers/exam_history_provider.dart';
import '../../../presentation/providers/exam_provider.dart';
import '../../../state/data_state.dart';
import '../../../state/app_state.dart';
import '../../../utils/back_guard.dart';

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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text('exam.title'.tr())),
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
          return _ExamIntro(
            onStart: (count, minutes, strictMode) => controller.start(
              (_randomSubset(questions, count)),
              minutes: minutes,
              strictMode: strictMode,
            ),
          );
        }
        final current = exam.currentQuestion;
        final locale = context.locale.languageCode;
        final questionText = _questionText(current, locale);
        final options = _options(current, locale);
        final selected = exam.answers[current.id];
        final isSkipped = exam.skipped.contains(current.id);
        final inProgress = exam.questions.isNotEmpty && !exam.isCompleted;
        final canProceed = selected != null || isSkipped;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Future<void> handleBack() async {
          final shell = TabShellScope.maybeOf(context);
          if (!inProgress) {
            if (shell != null) {
              shell.value = 0;
            } else {
              Navigator.of(context).maybePop();
            }
            return;
          }
          final shouldExit = await confirmExitExam(context);
          if (shouldExit && context.mounted) {
            if (shell != null) {
              controller.reset();
              shell.value = 0;
            } else {
              Navigator.of(context).maybePop();
            }
          }
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            final shell = TabShellScope.maybeOf(context);
            if (!inProgress) {
              if (shell != null) {
                shell.value = 0;
              } else {
                Navigator.of(context).pop();
              }
              return;
            }

            final shouldExit = await confirmExitExam(context);
            if (shouldExit && context.mounted) {
              if (shell != null) {
                controller.reset();
                shell.value = 0;
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: scheme.onSurface),
              leading: IconButton(
                onPressed: handleBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text(
                'exam.title'.tr(),
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, color: scheme.onSurface),
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () {
                      final settings = ref.read(appSettingsProvider);
                      if (settings.vibrationEnabled)
                        HapticFeedback.lightImpact();
                      if (settings.soundEnabled)
                        SystemSound.play(SystemSoundType.click);
                      controller.toggleFlag();
                    },
                    tooltip: 'exam.flag'.tr(),
                    icon: Icon(
                      exam.flagged.contains(current.id)
                          ? Icons.flag_rounded
                          : Icons.flag_outlined,
                      color: exam.flagged.contains(current.id)
                          ? AppColors.warning
                          : scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
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
                    // Timer & Progress Header
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TimerBanner(
                                  timeLeftSeconds: exam.timeLeftSeconds),
                              Text(
                                '${exam.currentIndex + 1}/${exam.questions.length}',
                                style: GoogleFonts.outfit(
                                  color:
                                      scheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (exam.currentIndex + 1) /
                                  exam.questions.length,
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
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        children: [
                          // Question Text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              questionText,
                              key: ValueKey(current.id),
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    scheme.onSurface.withValues(alpha: 0.7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                              ),
                              onPressed: () {
                                final settings = ref.read(appSettingsProvider);
                                if (settings.vibrationEnabled)
                                  HapticFeedback.lightImpact();
                                if (settings.soundEnabled)
                                  SystemSound.play(SystemSoundType.click);
                                controller.skipCurrent();
                                if (exam.currentIndex + 1 ==
                                    exam.questions.length) {
                                  controller.finish();
                                } else {
                                  controller.next();
                                }
                              },
                              child: Text('common.skip'.tr(),
                                  style: GoogleFonts.outfit(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Options
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey('${current.id}-options'),
                              children: List.generate(options.length, (idx) {
                                final optionText = options[idx];
                                final isSelected = selected == idx;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      final settings =
                                          ref.read(appSettingsProvider);
                                      if (settings.vibrationEnabled)
                                        HapticFeedback.lightImpact();
                                      if (settings.soundEnabled)
                                        SystemSound.play(SystemSoundType.click);
                                      controller.selectAnswer(idx);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? ModernTheme.secondary
                                                .withValues(alpha: 0.2)
                                            : (isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.05)
                                                : scheme.onSurface
                                                    .withValues(alpha: 0.04)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? ModernTheme.secondary
                                              : scheme.onSurface
                                                  .withValues(alpha: 0.12),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: ModernTheme.secondary
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : [],
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          _OptionBadge(
                                            label:
                                                String.fromCharCode(65 + idx),
                                            selected: isSelected,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              optionText,
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                color: scheme.onSurface
                                                    .withValues(alpha: 0.9),
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    GlassContainer(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.85),
                      blur: 10,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20,
                          32), // More padding at bottom for safe area
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.24)),
                                    foregroundColor: scheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  onPressed:
                                      exam.strictMode || exam.currentIndex == 0
                                          ? null
                                          : controller.previous,
                                  child: Text('common.previous'.tr(),
                                      style: GoogleFonts.outfit()),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ModernTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 8,
                                    shadowColor: ModernTheme.primary
                                        .withValues(alpha: 0.5),
                                  ),
                                  onPressed: canProceed
                                      ? () {
                                          final settings =
                                              ref.read(appSettingsProvider);
                                          if (settings.vibrationEnabled)
                                            HapticFeedback.mediumImpact();
                                          if (settings.soundEnabled)
                                            SystemSound.play(
                                                SystemSoundType.click);
                                          if (exam.currentIndex + 1 ==
                                              exam.questions.length) {
                                            controller.finish();
                                          } else {
                                            controller.next();
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    exam.currentIndex + 1 ==
                                            exam.questions.length
                                        ? 'exam.submit'.tr()
                                        : 'common.next'.tr(),
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!exam.strictMode || exam.isCompleted) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () =>
                                  _showQuestionGrid(context, exam, controller),
                              child: Text(
                                'exam.reviewAnswers'.tr(),
                                style: GoogleFonts.outfit(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.7)),
                              ),
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextButton.icon(
                                onPressed: () => _showQuestionGrid(
                                    context, exam, controller),
                                icon: Icon(Icons.grid_view_rounded,
                                    size: 16,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.45)),
                                label: Text('exam.overview'.tr(),
                                    style: GoogleFonts.outfit(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.45))),
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

  void _finishExam(BuildContext context, WidgetRef ref, ExamState exam) {
    final total = exam.questions.length;
    final correct = exam.answers.entries
        .where((e) =>
            exam.questions.firstWhere((q) => q.id == e.key).correctIndex ==
            e.value)
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
      questionAnswers: exam.questions
          .map((q) => QuestionAnswer(
                questionId: q.id,
                userAnswerIndex: exam.answers[q.id] ?? -1,
                correctAnswerIndex: q.correctIndex,
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
      final category = question.categoryId;
      if (entry.value == question.correctIndex) {
        scores[category] = (scores[category] ?? 0) + 1;
      }
    }
    return scores;
  }

  void _showQuestionGrid(
      BuildContext context, ExamState exam, ExamController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.95)
              : scheme.surface.withValues(alpha: 0.95),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: exam.questions.length,
                  itemBuilder: (context, index) {
                    final question = exam.questions[index];
                    final answered = exam.answers.containsKey(question.id);
                    final flagged = exam.flagged.contains(question.id);
                    final isCurrent = exam.currentIndex == index;

                    Color color = isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : scheme.onSurface.withValues(alpha: 0.04);
                    Color border = Colors.transparent;
                    Color text = scheme.onSurface.withValues(alpha: 0.7);

                    if (isCurrent) {
                      border = ModernTheme.secondary;
                      text = scheme.onSurface;
                    } else if (flagged) {
                      color = AppColors.warning.withValues(alpha: 0.2);
                      text = AppColors.warning;
                    } else if (answered) {
                      color = ModernTheme.secondary.withValues(alpha: 0.2);
                      text = ModernTheme.secondary;
                    }

                    return InkWell(
                      onTap: () {
                        controller.goTo(index);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: 2),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.outfit(
                            color: text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<Question> _randomSubset(List<Question> questions, int count) {
  final items = List<Question>.from(questions)..shuffle();
  final safeCount = count > items.length ? items.length : count;
  return items.take(safeCount).toList();
}

// ... (Copy _questionText and _options helpers from practice_screen or create a shared util?
// For now, I'll duplicate to keep file self-contained as requested, or import if they were public.
// They are private in practice_screen. I will duplicate.)

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

class _ExamIntro extends StatefulWidget {
  const _ExamIntro({required this.onStart});

  final void Function(int count, int minutes, bool strictMode) onStart;

  @override
  State<_ExamIntro> createState() => _ExamIntroState();
}

class _ExamIntroState extends State<_ExamIntro> {
  final bool _strictMode = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('exam.title'.tr(),
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassContainer(
                gradient: ModernTheme.secondaryGradient,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'exam.title'.tr(),
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'exam.readyTitle'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'exam.description'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'exam.selectMode'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _ModeGlassCard(
                title: 'exam.modes.quick'.tr(),
                questions: '20',
                minutes: '15',
                icon: Icons.bolt_rounded,
                color: Colors.amber,
                onTap: () => _confirmStart(context, 20, 15),
              ),
              const SizedBox(height: 12),
              _ModeGlassCard(
                title: 'exam.modes.standard'.tr(),
                questions: '30',
                minutes: '20',
                icon: Icons.speed_rounded,
                color: ModernTheme.secondary,
                isRecommended: true,
                onTap: () => _confirmStart(context, 30, 20),
              ),
              const SizedBox(height: 12),
              _ModeGlassCard(
                title: 'exam.modes.full'.tr(),
                questions: '40',
                minutes: '30',
                icon: Icons.workspace_premium_rounded,
                color: Colors.purpleAccent,
                onTap: () => _confirmStart(context, 40, 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmStart(
      BuildContext context, int count, int minutes) async {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : scheme.surface,
        title: Row(
          children: [
            Icon(Icons.timer_outlined, color: ModernTheme.secondary),
            const SizedBox(width: 12),
            Text('exam.title'.tr(),
                style: GoogleFonts.outfit(
                    color: scheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'exam.disclaimer'.tr(),
          style: GoogleFonts.outfit(
              color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr(),
                style: GoogleFonts.outfit(
                    color: scheme.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.secondary,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text('exam.startExam'.tr(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      widget.onStart(count, minutes, _strictMode);
    }
  }
}

class _ModeGlassCard extends StatelessWidget {
  const _ModeGlassCard({
    required this.title,
    required this.questions,
    required this.minutes,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isRecommended = false,
  });

  final String title;
  final String questions;
  final String minutes;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final settings =
            ProviderScope.containerOf(context).read(appSettingsProvider);
        if (settings.vibrationEnabled) HapticFeedback.lightImpact();
        if (settings.soundEnabled) SystemSound.play(SystemSoundType.click);
        onTap();
      },
      child: GlassContainer(
        color: isRecommended
            ? color.withValues(alpha: 0.15)
            : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : scheme.onSurface.withValues(alpha: 0.04)),
        border: Border.all(
          color: isRecommended
              ? color.withValues(alpha: 0.5)
              : scheme.onSurface.withValues(alpha: 0.1),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'exam.bestBadge'.tr(),
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'exam.modeSummary'.tr(namedArgs: {
                      'questions': questions,
                      'minutes': minutes,
                    }),
                    style: GoogleFonts.outfit(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: scheme.onSurface.withValues(alpha: 0.3), size: 16),
          ],
        ),
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
    final totalSeconds = timeLeftSeconds;

    Color bg = ModernTheme.secondary.withValues(alpha: 0.2);
    Color text = ModernTheme.secondary;

    if (totalSeconds <= 60) {
      bg = AppColors.error.withValues(alpha: 0.2);
      text = AppColors.error;
    } else if (totalSeconds <= 300) {
      bg = AppColors.warning.withValues(alpha: 0.2);
      text = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: text, size: 16),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: GoogleFonts.robotoMono(
              // Monospace for timer
              fontWeight: FontWeight.bold,
              color: text,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  const _OptionBadge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? ModernTheme.secondary : Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
