import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../models/question.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
import '../../../state/data_state.dart';
import '../../../utils/text_formatters.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.result});

  final ExamResult result;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  String _filter = 'all'; // 'all', 'correct', 'incorrect', 'skipped'

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final signsAsync = ref.watch(signsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'review.title'.tr(),
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: scheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: questionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('common.error'.tr())),
            data: (questions) {
              final questionMap = {for (final q in questions) q.id: q};
              final signMap = signsAsync.valueOrNull == null
                  ? <String, String>{}
                  : {for (final s in signsAsync.valueOrNull!) s.id: s.svgPath};

              final allAnswers = widget.result.questionAnswers;
              final filteredAnswers = allAnswers.where((a) {
                if (_filter == 'correct') return a.isCorrect;
                if (_filter == 'incorrect') return !a.isCorrect && !a.isSkipped;
                if (_filter == 'skipped') return a.isSkipped;
                return true;
              }).toList();

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: filteredAnswers.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _ReviewHeader(result: widget.result);
                  }
                  if (index == 1) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _ReviewFilterChip(
                            label: '${'quiz.categories.all'.tr()} (${allAnswers.length})',
                            selected: _filter == 'all',
                            onTap: () => setState(() => _filter = 'all'),
                          ),
                          const SizedBox(width: 8),
                          _ReviewFilterChip(
                            label: '${'results.correct'.tr()} (${widget.result.correctAnswers})',
                            selected: _filter == 'correct',
                            color: ModernTheme.emerald,
                            onTap: () => setState(() => _filter = 'correct'),
                          ),
                          const SizedBox(width: 8),
                          _ReviewFilterChip(
                            label: '${'results.incorrect'.tr()} (${widget.result.wrongAnswers})',
                            selected: _filter == 'incorrect',
                            color: ModernTheme.coral,
                            onTap: () => setState(() => _filter = 'incorrect'),
                          ),
                          const SizedBox(width: 8),
                          _ReviewFilterChip(
                            label: '${'review.skipped'.tr()} (${widget.result.skippedAnswers})',
                            selected: _filter == 'skipped',
                            color: ModernTheme.amber,
                            onTap: () => setState(() => _filter = 'skipped'),
                          ),
                        ],
                      ),
                    );
                  }

                  final answer = filteredAnswers[index - 2];
                  final originalIndex = allAnswers.indexOf(answer) + 1;
                  final question = questionMap[answer.questionId];
                  if (question == null) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('review.missingQuestion'.tr()),
                    );
                  }
                  return _ReviewCard(
                    index: originalIndex,
                    question: question,
                    answer: answer,
                    signPath: question.signId == null
                        ? null
                        : signMap[question.signId!],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  const _ReviewFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? ModernTheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: () {
          AppFeedback.tap(context);
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? activeColor
                : (isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? activeColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : scheme.outline.withValues(alpha: 0.12)),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Text(
            label,
            style: AppFonts.outfit(
              context,
              color: selected
                  ? Colors.white
                  : scheme.onSurface.withValues(alpha: 0.8),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final passed = result.passed;
    final color = passed ? ModernTheme.emerald : ModernTheme.coral;
    final accuracy = result.scorePercentage.toStringAsFixed(0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passed ? 'results.passed'.tr() : 'results.failed'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCorrectAnswers(context, result.correctAnswers,
                          result.totalQuestions),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$accuracy%',
                style: AppFonts.outfit(
                  context,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : scheme.outline.withValues(alpha: 0.15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor:
                        scheme.onSurface.withValues(alpha: 0.8),
                  ),
                  onPressed: () {
                    AppFeedback.tap(context);
                    context.pushReplacement('/home');
                  },
                  child: Text(
                    'results.backHome'.tr(),
                    style: AppFonts.outfit(
                      context,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
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
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    shadowColor: ModernTheme.primary.withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    AppFeedback.tap(context);
                    context.pushReplacement('/exam');
                  },
                  child: Text(
                    'exam.tryAgain'.tr(),
                    style: AppFonts.outfit(
                      context,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.signPath,
  });

  final int index;
  final Question question;
  final QuestionAnswer answer;
  final String? signPath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = context.locale.languageCode;
    final questionText = _questionText(question, locale);
    final options = _options(question, locale);
    final correct = answer.correctAnswerIndex;
    final selected = answer.userAnswerIndex;
    final isSkipped = answer.isSkipped;
    final isCorrect = answer.isCorrect;
    final statusColor = isSkipped
        ? Colors.orangeAccent
        : (isCorrect ? ModernTheme.tertiary : scheme.error);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$index',
                  style: AppFonts.outfit(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSkipped
                          ? Icons.help_outline_rounded
                          : (isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded),
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSkipped
                          ? 'review.skipped'.tr().toUpperCase()
                          : (isCorrect
                              ? 'results.correct'.tr().toUpperCase()
                              : 'results.incorrect'.tr().toUpperCase()),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            questionText,
            style: AppFonts.outfit(
              context,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              height: 1.4,
            ),
          ),
          if (signPath != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : scheme.onSurface.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SvgPicture.asset(
                  'assets/$signPath',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...List.generate(options.length, (idx) {
            final optionText = options[idx];
            final isSelected = idx == selected;
            final isCorrectOption = idx == correct;

            Color? border;
            Color? fill;
            Color iconColor;
            IconData? icon;

            if (isCorrectOption) {
              border = ModernTheme.emerald;
              fill = ModernTheme.emerald.withValues(alpha: 0.1);
              iconColor = ModernTheme.emerald;
              icon = Icons.check_circle_rounded;
            } else if (isSelected && !isCorrectOption) {
              border = ModernTheme.coral;
              fill = ModernTheme.coral.withValues(alpha: 0.1);
              iconColor = ModernTheme.coral;
              icon = Icons.cancel_rounded;
            } else {
              border = isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : scheme.outline.withValues(alpha: 0.1);
              fill = Colors.transparent;
              iconColor = scheme.onSurface.withValues(alpha: 0.3);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: border,
                  width: (isCorrectOption || isSelected) ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + idx),
                      style: AppFonts.outfit(
                        context,
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: AppFonts.outfit(
                        context,
                        fontSize: 14,
                        color: scheme.onSurface.withValues(
                            alpha: (isSelected || isCorrectOption) ? 1.0 : 0.75),
                        fontWeight: (isSelected || isCorrectOption)
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: iconColor, size: 20),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'review.explanation'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.primary,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ModernTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ModernTheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    _explanation(question, locale),
                    style: AppFonts.outfit(
                      context,
                      fontSize: 13.5,
                      color: scheme.onSurface.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _questionText(Question question, String locale) {
  // Try current locale embedded text first
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
  // Fallback to English embedded text
  if (question.questionText != null) return question.questionText!;
  // Final fallback to translation key
  return question.questionKey.tr();
}

List<String> _options(Question question, String locale) {
  // Try current locale embedded options first
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
  if (localeOptions != null && localeOptions.isNotEmpty) {
    return localeOptions;
  }
  // Fallback to English embedded options
  if (question.options != null && question.options!.isNotEmpty) {
    return question.options!;
  }
  // Final fallback to translation keys
  return question.optionsKeys.map((key) => key.tr()).toList();
}

String _explanation(Question question, String locale) {
  // Try current locale embedded explanation first
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
  // Fallback to English embedded explanation
  if (question.explanation != null) return question.explanation!;
  // Final fallback to translation key
  return question.explanationKey?.tr() ?? 'quiz.explanationFallback'.tr();
}
