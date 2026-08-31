import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/home_shell.dart';
import '../../../widgets/standard_question_view.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../models/question.dart';
import '../../../presentation/providers/exam_history_provider.dart';
import '../../../presentation/providers/exam_provider.dart';
import '../../../state/data_state.dart';
import '../../../state/app_state.dart';
import '../../../services/ad_service.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/back_guard.dart';
import '../../../utils/navigation_utils.dart';

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
    final signsAsync = ref.watch(signsProvider);
    final exam = ref.watch(
      examProvider.select(
        (state) => (
          questions: state.questions,
          currentIndex: state.currentIndex,
          answers: state.answers,
          skipped: state.skipped,
          flagged: state.flagged,
          isCompleted: state.isCompleted,
          strictMode: state.strictMode,
          originalDurationSeconds: state.originalDurationSeconds,
        ),
      ),
    );
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
                const SizedBox(height: 12),
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
                if (!context.mounted) return;
                _finishExam(context, ref, ref.read(examProvider));
                // Defer reset so GoRouter push completes before state clears
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.reset();
                });
              });
            }
            return const SizedBox.shrink();
          }
          return _ExamIntro(
            onStart: (count, minutes, strictMode) => controller.start(
              _buildExamQuestions(
                questions,
                count,
                _minSignQuota(count),
              ),
              minutes: minutes,
              strictMode: strictMode,
            ),
          );
        }
        final current = exam.questions[exam.currentIndex];
        final signMap = signsAsync.valueOrNull == null
            ? <String, String>{}
            : {for (final s in signsAsync.valueOrNull!) s.id: s.svgPath};
        final signPath =
            current.signId != null ? signMap[current.signId!] : null;
        final locale = context.locale.languageCode;
        final questionText = _questionText(current, locale);
        final options = _options(current, locale);
        final selected = exam.answers[current.id];
        final shell = TabShellScope.maybeOf(context);
        final isActiveTab = shell == null || shell.value == 3;
        final examStarted = exam.questions.isNotEmpty &&
            !exam.isCompleted &&
            (exam.answers.isNotEmpty ||
                exam.currentIndex > 0 ||
                exam.originalDurationSeconds > 0);
        final canProceed = selected != null;
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Future<void> exitExam() async {
          controller.reset();
          if (!context.mounted) return;
          if (shell != null) {
            shell.value = 0;
            return;
          }
          context.go('/home');
        }

        Future<void> handleBack() async {
          if (!examStarted) {
            await handleAppBack(context);
            return;
          }
          final shouldExit = await confirmExitExam(context);
          if (!shouldExit || !context.mounted) return;
          await exitExam();
        }

        return PopScope(
          canPop: isActiveTab ? !examStarted : true,
          onPopInvokedWithResult: (didPop, _) async {
            if (!isActiveTab) return;
            if (!examStarted) {
              if (!didPop) {
                await handleAppBack(context, fromPopScope: true);
              }
              return;
            }
            if (didPop) return;
            final shouldExit = await confirmExitExam(context);
            if (!shouldExit || !context.mounted) return;
            await exitExam();
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: scheme.onSurface),
              leading: IconButton(
                onPressed: handleBack,
                icon: const Icon(Icons.close_rounded), // Formal close icon
              ),
              title: Text(
                'exam.title'.tr(),
                style: AppFonts.outfit(context,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: scheme.onSurface),
              ),
              centerTitle: true,
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final timeLeftSeconds = ref.watch(
                          examProvider.select(
                            (state) => state.timeLeftSeconds,
                          ),
                        );
                        return _TimerBanner(
                          timeLeftSeconds: timeLeftSeconds,
                        );
                      },
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
                    // Progress Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${'exam.questions'.tr()} ${exam.currentIndex + 1}/${exam.questions.length}',
                                      style: AppFonts.outfit(
                                        context,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    if (exam.strictMode)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: scheme.error
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'STRICT',
                                          style: AppFonts.outfit(
                                            context,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: scheme.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: (exam.currentIndex + 1) /
                                        exam.questions.length,
                                    backgroundColor: scheme.onSurface
                                        .withValues(alpha: 0.05),
                                    color: scheme.primary,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
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
                            // Question + options (shared standard component)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: StandardQuestionView(
                                key: ValueKey(current.id),
                                questionText: questionText,
                                optionTexts: options,
                                selectedIndex: selected,
                                correctIndex: current.correctIndex,
                                revealed: exam.isCompleted,
                                signPath: signPath,
                                onSelect: exam.isCompleted
                                    ? null
                                    : (idx) {
                                        AppFeedback.tap(context);
                                        controller.selectAnswer(idx);
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions Bar
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF0F172A) : scheme.surface,
                        border: Border(
                          top: BorderSide(
                              color: scheme.onSurface.withValues(alpha: 0.08)),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 16, 20,
                          16 + MediaQuery.paddingOf(context).bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!exam.strictMode) ...[
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.25),
                                        width: 1),
                                    foregroundColor: scheme.onSurface
                                        .withValues(alpha: 0.7),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    textStyle: AppFonts.outfit(context,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: exam.currentIndex == 0
                                      ? null
                                      : controller.previous,
                                  icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 16),
                                  label: Text('common.previous'.tr()),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: ModernTheme.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        ModernTheme.primary
                                            .withValues(alpha: 0.4),
                                    disabledForegroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    textStyle: AppFonts.outfit(context,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  onPressed: canProceed
                                      ? () {
                                          AppFeedback.confirm(context);
                                          if (exam.currentIndex + 1 ==
                                              exam.questions.length) {
                                            controller.finish();
                                          } else {
                                            controller.next();
                                          }
                                        }
                                      : null,
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(
                                      Icons.arrow_forward_rounded, size: 18),
                                  label: Text(
                                    exam.currentIndex + 1 ==
                                            exam.questions.length
                                        ? 'exam.submit'.tr()
                                        : 'common.next'.tr(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!exam.strictMode || exam.isCompleted) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => _showQuestionGrid(
                                context,
                                ref.read(examProvider),
                                controller,
                              ),
                              icon:
                                  const Icon(Icons.grid_view_rounded, size: 18),
                              label: Text(
                                'exam.reviewAnswers'.tr(),
                                style: AppFonts.outfit(context,
                                    color:
                                        scheme.onSurface.withValues(alpha: 0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
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
    ref
        .read(appSettingsProvider.notifier)
        .updateStats(correct: correct, total: total);
    ref.read(examHistoryProvider.notifier).addResult(result);
    if (!context.mounted) return;
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
                      color = Colors.orangeAccent.withValues(alpha: 0.2);
                      text = Colors.orangeAccent;
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
                          style: AppFonts.outfit(
                            context,
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

int _minSignQuota(int count) {
  switch (count) {
    case 20:
      return 3;
    case 30:
      return 5;
    case 40:
      return 8;
    default:
      return 0;
  }
}

List<Question> _buildExamQuestions(
    List<Question> questions, int count, int minSigns) {
  final signPool =
      questions.where((q) => q.signId != null && q.signId!.isNotEmpty).toList();
  final otherPool =
      questions.where((q) => q.signId == null || q.signId!.isEmpty).toList();

  signPool.shuffle();
  otherPool.shuffle();

  final selected = <Question>[];
  final signPickCount = signPool.length < minSigns ? signPool.length : minSigns;
  selected.addAll(signPool.take(signPickCount));

  if (signPool.length < minSigns && kDebugMode) {
    debugPrint(
      'Exam sign quota short: need=$minSigns, available=${signPool.length}',
    );
  }

  var remaining = count - selected.length;
  if (remaining > 0) {
    final otherTake =
        remaining > otherPool.length ? otherPool.length : remaining;
    selected.addAll(otherPool.take(otherTake));
    remaining = count - selected.length;
  }

  if (remaining > 0) {
    selected.addAll(signPool.skip(signPickCount).take(remaining));
    remaining = count - selected.length;
  }

  if (remaining > 0) {
    final used = selected.map((q) => q.id).toSet();
    final fallback = questions.where((q) => !used.contains(q.id)).toList()
      ..shuffle();
    selected.addAll(fallback.take(remaining));
  }

  selected.shuffle();

  if (kDebugMode) {
    final signCount =
        selected.where((q) => q.signId != null && q.signId!.isNotEmpty).length;
    debugPrint(
      'Exam mix: total=${selected.length}, signs=$signCount, min=$minSigns',
    );
  }

  return selected;
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
  if (question.options != null && question.options!.isNotEmpty) {
    return question.options!;
  }
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
            style: AppFonts.outfit(context,
                fontWeight: FontWeight.bold, color: scheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        leading: IconButton(
          onPressed: () => handleAppBack(context),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ModernTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ModernTheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'exam.title'.tr(),
                        style: AppFonts.outfit(context,
                            color: ModernTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'exam.readyTitle'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'exam.description'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 15,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'exam.selectMode'.tr(),
                style: AppFonts.outfit(
                  context,
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

  Future<void> _handleExamStart(
      BuildContext context, int count, int minutes) async {
    final prefs = ProviderScope.containerOf(context).read(sharedPrefsProvider);
    final freeUsed = prefs.getBool('examFreeUsed') ?? false;
    final tokens = prefs.getInt('examRewardTokenCount') ?? 0;
    if (!freeUsed) {
      await prefs.setBool('examFreeUsed', true);
      widget.onStart(count, minutes, _strictMode);
      return;
    }
    if (tokens > 0) {
      await prefs.setInt('examRewardTokenCount', tokens - 1);
      widget.onStart(count, minutes, _strictMode);
      return;
    }
    final unlocked = await _showRewardedUnlock(context);
    if (unlocked) {
      widget.onStart(count, minutes, _strictMode);
    }
  }

  Future<bool> _showRewardedUnlock(BuildContext context) async {
    // Hoisted so cleanup is accessible after showDialog returns.
    VoidCallback? notifierListener;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool loading = false;
        String? errorMessage;
        bool didTriggerLoad = false;
        // Listen to the reactive notifier so the dialog auto-updates
        // when the rewarded ad loads in the background.
        return StatefulBuilder(
          builder: (context, setState) {
            final scheme = Theme.of(context).colorScheme;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            if (!didTriggerLoad) {
              didTriggerLoad = true;
              // Set up listener for background ad readiness.
              notifierListener = () {
                if (!context.mounted) return;
                if (AdService.instance.isRewardedReady) {
                  setState(() {
                    loading = false;
                    errorMessage = null;
                  });
                }
              };
              AdService.instance.rewardedReadyNotifier
                  .addListener(notifierListener!);
              // If the ad is already preloaded, skip loading entirely.
              if (AdService.instance.isRewardedReady) {
                // Ad is already ready — no loading needed.
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!context.mounted) return;
                  setState(() {
                    loading = true;
                    errorMessage = null;
                  });
                  await AdService.instance.init();
                  final loaded = await AdService.instance.ensureRewardedReady();
                  if (!context.mounted) return;
                  setState(() {
                    loading = false;
                    if (!loaded) {
                      errorMessage = 'ads.unavailable'.tr();
                    }
                  });
                });
              }
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: GlassContainer(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : scheme.surface.withValues(alpha: 0.96),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.02),
                        ]
                      : [
                          scheme.surface,
                          scheme.surface.withValues(alpha: 0.9),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ModernTheme.secondary.withValues(alpha: 0.9),
                                ModernTheme.primary.withValues(alpha: 0.85),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ads.unlockExamTitle'.tr(),
                            style: AppFonts.outfit(
                              context,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ads.unlockExamBody'.tr(),
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: AppFonts.outfit(
                          context,
                          color: scheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.onSurface,
                              side: BorderSide(
                                color: scheme.onSurface.withValues(alpha: 0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : () => Navigator.of(context).pop(false),
                            child: Text(
                              'ads.notNow'.tr(),
                              style: AppFonts.outfit(
                                context,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ModernTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                              shadowColor:
                                  ModernTheme.primary.withValues(alpha: 0.35),
                            ),
                            onPressed: loading
                                ? null
                                : () async {
                                    setState(() => loading = true);
                                    errorMessage = null;
                                    await AdService.instance.init();
                                    if (!AdService.instance.isRewardedReady) {
                                      final loaded = await AdService.instance
                                          .ensureRewardedReady();
                                      if (!loaded && context.mounted) {
                                        setState(() {
                                          loading = false;
                                          errorMessage = 'ads.unavailable'.tr();
                                        });
                                        return;
                                      }
                                    }
                                    var rewardedHandled = false;
                                    final success =
                                        await AdService.instance.showRewarded(
                                      onReward: () {
                                        if (rewardedHandled) {
                                          return;
                                        }
                                        rewardedHandled = true;
                                        // Clean up listener before popping.
                                        if (notifierListener != null) {
                                          AdService
                                              .instance.rewardedReadyNotifier
                                              .removeListener(
                                                  notifierListener!);
                                        }
                                        Navigator.of(context).pop(true);
                                      },
                                    );
                                    if (!success && context.mounted) {
                                      setState(() {
                                        loading = false;
                                        errorMessage = 'ads.unavailable'.tr();
                                      });
                                    }
                                  },
                            child: loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'ads.watchAd'.tr(),
                                    style: AppFonts.outfit(context,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    // Clean up the notifier listener when dialog closes.
    if (notifierListener != null) {
      AdService.instance.rewardedReadyNotifier
          .removeListener(notifierListener!);
    }
    return result ?? false;
  }

  Future<void> _confirmStart(
      BuildContext context, int count, int minutes) async {
    await _handleExamStart(context, count, minutes);
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
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: () {
          AppFeedback.tap(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRecommended
                  ? ModernTheme.primary.withValues(alpha: 0.5)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : scheme.outline.withValues(alpha: 0.12)),
              width: isRecommended ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isRecommended
                    ? ModernTheme.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.outfit(
                              context,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ModernTheme.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ModernTheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'exam.bestBadge'.tr(),
                              style: AppFonts.outfit(
                                context,
                                color: ModernTheme.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
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
                      style: AppFonts.outfit(
                        context,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ],
          ),
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

    Color bg = ModernTheme.primary.withValues(alpha: 0.15);
    Color text = ModernTheme.primary;

    if (totalSeconds <= 60) {
      bg = ModernTheme.coral.withValues(alpha: 0.18);
      text = ModernTheme.coral;
    } else if (totalSeconds <= 300) {
      bg = ModernTheme.amber.withValues(alpha: 0.18);
      text = ModernTheme.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: text.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsFill.timer, color: text, size: 16),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.w700,
              color: text,
              fontSize: 13.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
