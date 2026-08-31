import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/modern_theme.dart';
import '../../data/models/curriculum_model.dart';
import '../../presentation/providers/curriculum_progress_provider.dart';
import '../../services/ad_service.dart';
import '../../utils/app_feedback.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_toast.dart';
import '../../widgets/confetti_overlay.dart';
import '../../widgets/standard_question_view.dart';

/// A short comprehension quiz for a curriculum module.
class ModuleQuizScreen extends ConsumerStatefulWidget {
  const ModuleQuizScreen({super.key, required this.module});

  final CurriculumModule module;

  @override
  ConsumerState<ModuleQuizScreen> createState() => _ModuleQuizScreenState();
}

class _ModuleQuizScreenState extends ConsumerState<ModuleQuizScreen> {
  late List<CurriculumQuizQuestion> _questions;
  int _index = 0;
  int? _selected;
  int _correctCount = 0;
  bool _finished = false;

  static const int _passThreshold = 70;

  @override
  void initState() {
    super.initState();
    final questions = List<CurriculumQuizQuestion>.of(widget.module.quizQuestions)
      ..shuffle(Random());
    _questions = questions.take(8).toList();
  }

  void _restart() {
    final questions = List<CurriculumQuizQuestion>.of(widget.module.quizQuestions)
      ..shuffle(Random());
    setState(() {
      _questions = questions.take(8).toList();
      _index = 0;
      _selected = null;
      _correctCount = 0;
      _finished = false;
    });
  }

  /// Watches a rewarded ad for an immediate retry of a failed quiz.
  Future<void> _showSecondChance() async {
    final rewarded = await AdService.instance.showRewarded(
      onReward: () {
        if (mounted) _restart();
      },
    );
    if (!rewarded && mounted) {
      showAppToast(context, 'ads.unavailable'.tr(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'journey.quizTitle'.tr(),
          style: AppFonts.outfit(context,
              fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded, size: 22),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: _finished
              ? _buildResult(scheme)
              : _buildQuestion(scheme),
        ),
      ),
    );
  }

  Widget _buildQuestion(ColorScheme scheme) {
    final question = _questions[_index];

    return Column(
      children: [
        // Progress header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'journey.quizProgress'.tr(namedArgs: {
                      'current': (_index + 1).toString(),
                      'total': _questions.length.toString(),
                    }),
                    style: AppFonts.outfit(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant),
                  ),
                  Text(
                    'journey.quizPassLabel'.tr(),
                    style: AppFonts.outfit(context,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ModernTheme.amber),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 6,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              StandardQuestionView(
                questionText: question.question,
                optionTexts: question.options,
                selectedIndex: _selected,
                correctIndex: question.correctIndex,
                revealed: _selected != null,
                onSelect: _selected == null
                    ? (idx) => _selectAnswer(idx, question.correctIndex)
                    : null,
              ),
              const SizedBox(height: 16),
              if (_selected != null)
                _ExplanationCard(explanation: question.explanation),
            ],
          ),
        ),

        // Next button
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selected == null ? null : () => _next(),
                style: FilledButton.styleFrom(
                  backgroundColor: ModernTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      ModernTheme.primary.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: AppFonts.outfit(context,
                      fontSize: 15, fontWeight: FontWeight.w800),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  _index == _questions.length - 1
                      ? 'journey.quizFinish'.tr()
                      : 'journey.quizNext'.tr(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectAnswer(int index, int correctIndex) {
    AppFeedback.selection(context);
    setState(() {
      _selected = index;
      if (index == correctIndex) _correctCount += 1;
    });
  }

  void _next() {
    AppFeedback.tap(context);
    if (_index == _questions.length - 1) {
      _finish();
    } else {
      setState(() {
        _index += 1;
        _selected = null;
      });
    }
  }

  void _finish() {
    final total = _questions.length;
    final percentage = total == 0
        ? 0
        : ((_correctCount / total) * 100).round();

    ref
        .read(curriculumProgressProvider.notifier)
        .recordModuleQuizScore(widget.module.unitId, percentage);

    setState(() {
      _finished = true;
    });
    AppFeedback.confirm(context);
  }

  Widget _buildResult(ColorScheme scheme) {
    final total = _questions.length;
    final percentage = total == 0
        ? 0
        : ((_correctCount / total) * 100).round();
    final passed = percentage >= _passThreshold;

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: passed
                  ? ModernTheme.emeraldGradient
                  : LinearGradient(
                      colors: [Colors.orange.shade700, Colors.orange.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: (passed ? ModernTheme.emerald : Colors.orange.shade600)
                      .withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: AppFonts.outfit(context,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  Text(
                    'journey.quizScore'.tr(namedArgs: {
                      'correct': _correctCount.toString(),
                      'total': total.toString(),
                    }),
                    style: AppFonts.outfit(context,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            passed ? 'journey.quizResultPass'.tr() : 'journey.quizResultFail'.tr(),
            style: AppFonts.outfit(context,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: passed ? ModernTheme.emerald : Colors.orange.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            passed
                ? 'journey.quizResultPassDesc'.tr()
                : 'journey.quizResultFailDesc'.tr(namedArgs: {
                    'threshold': _passThreshold.toString(),
                  }),
            style: AppFonts.outfit(context,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (!passed) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showSecondChance,
                icon: Icon(PhosphorIcons.play(), size: 20),
                label: Text(
                  'journey.quizSecondChance'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: passed ? ModernTheme.emerald : scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                passed ? 'journey.quizDone'.tr() : 'journey.quizTryAgain'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (passed) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'journey.quizBackToModule'.tr(),
                style: AppFonts.outfit(context,
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );

    if (passed) {
      return ConfettiOverlay(
        autoStart: true,
        child: content,
      );
    }
    return content;
  }
}


class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation});

  final String explanation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (explanation.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade600.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.lightbulb,
              color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'journey.quizExplanation'.tr(),
                  style: AppFonts.outfit(context,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: AppFonts.outfit(context,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: scheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
