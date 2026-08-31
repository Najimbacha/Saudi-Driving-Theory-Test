import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/modern_theme.dart';
import '../../../data/models/exam_result_model.dart';
import '../../../utils/app_feedback.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/text_formatters.dart';
import '../../../widgets/confetti_overlay.dart';
import '../../../widgets/exam_certificate_dialog.dart';

/// A modern, polished result screen for both exam simulations and practice
/// quizzes: animated score ring, status pill, stat tiles and clear actions.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});

  final ExamResult result;

  bool get _isExam => result.examType == 'exam';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isExam ? 'results.title'.tr() : 'results.practiceTitle'.tr(),
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
          onPressed: () => context.pushReplacement('/home'),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: ConfettiOverlay(
        autoStart: result.passed,
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _ScoreCard(result: result),
                const SizedBox(height: 20),

                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _StatTile(
                      label: 'results.correct'.tr(),
                      value: '${result.correctAnswers}',
                      icon: PhosphorIconsFill.checkCircle,
                      color: ModernTheme.emerald,
                    ),
                    _StatTile(
                      label: 'results.incorrect'.tr(),
                      value: '${result.wrongAnswers}',
                      icon: PhosphorIconsFill.xCircle,
                      color: ModernTheme.coral,
                    ),
                    _StatTile(
                      label: 'results.accuracy'.tr(),
                      value:
                          '${result.scorePercentage.toStringAsFixed(0)}%',
                      icon: PhosphorIconsFill.target,
                      color: ModernTheme.primary,
                    ),
                    _StatTile(
                      label: 'results.time'.tr(),
                      value: formatDuration(result.timeTakenSeconds),
                      icon: PhosphorIconsFill.timer,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Category breakdown
                if (result.categoryScores.isNotEmpty)
                  _CategoryBreakdown(result: result),

                const SizedBox(height: 24),

                // Actions
                if (result.passed && _isExam) ...[
                  _ActionButton(
                    gradient: ModernTheme.goldMetallicGradient,
                    icon: PhosphorIconsFill.certificate,
                    label: 'results.certificate'.tr(),
                    onTap: () => ExamCertificateDialog.show(context, result),
                  ),
                  const SizedBox(height: 12),
                ],

                _ActionButton(
                  gradient: ModernTheme.primaryGradient,
                  icon: PhosphorIconsFill.arrowsClockwise,
                  label: _isExam ? 'exam.tryAgain'.tr() : 'practice.tryAgain'.tr(),
                  onTap: () {
                    AppFeedback.tap(context);
                    context.pushReplacement(_isExam ? '/exam' : '/practice');
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : scheme.outline.withValues(alpha: 0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor:
                              scheme.onSurface.withValues(alpha: 0.8),
                        ),
                        onPressed: () {
                          AppFeedback.tap(context);
                          context.push('/review', extra: result);
                        },
                        icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
                        label: Text(
                          'results.reviewAnswers'.tr(),
                          style: AppFonts.outfit(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : scheme.outline.withValues(alpha: 0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor:
                              scheme.onSurface.withValues(alpha: 0.8),
                        ),
                        onPressed: () {
                          AppFeedback.tap(context);
                          context.pushReplacement('/home');
                        },
                        icon: const Icon(Icons.home_rounded, size: 18),
                        label: Text(
                          'results.backHome'.tr(),
                          style: AppFonts.outfit(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = passed ? ModernTheme.emerald : ModernTheme.coral;
    final score = result.scorePercentage.round();
    final gradient = passed
        ? ModernTheme.emeraldGradient
        : const LinearGradient(
            colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsFill.warningCircle,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  passed ? 'results.passed'.tr() : 'results.failed'.tr(),
                  style: AppFonts.outfit(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Animated score ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            scheme.onSurface.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}%',
                          style: AppFonts.outfit(
                            context,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCorrectAnswers(
                              context, result.correctAnswers, result.totalQuestions),
                          style: AppFonts.outfit(
                            context,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // Summary line
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsFill.student,
                    color: color, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    passed
                        ? 'results.encouragement'.tr()
                        : 'results.tryAgainHint'.tr(),
                    style: AppFonts.outfit(
                      context,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withValues(alpha: 0.7),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: AppFonts.outfit(
                      context,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = result.categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.chartBar,
                  color: scheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'results.categoryBreakdown'.tr(),
                style: AppFonts.outfit(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...categories.map((entry) {
            final label = entry.key;
            final count = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'categories.$label.title'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface.withValues(alpha: 0.75),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ModernTheme.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: AppFonts.outfit(
                        context,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ModernTheme.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Gradient gradient;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppFonts.outfit(
                  context,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
