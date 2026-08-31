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

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final accuracy = result.scorePercentage.toStringAsFixed(0);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'results.title'.tr(),
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
                _HeroScore(result: result),
                const SizedBox(height: 20),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatSmallCard(
                    label: 'results.correct'.tr(),
                    value: '${result.correctAnswers}',
                    icon: PhosphorIconsFill.checkCircle,
                    color: ModernTheme.emerald,
                  ),
                  _StatSmallCard(
                    label: 'results.incorrect'.tr(),
                    value: '${result.wrongAnswers}',
                    icon: PhosphorIconsFill.xCircle,
                    color: ModernTheme.coral,
                  ),
                  _StatSmallCard(
                    label: 'results.accuracy'.tr(),
                    value: '$accuracy%',
                    icon: PhosphorIconsFill.target,
                    color: ModernTheme.primary,
                  ),
                  _StatSmallCard(
                    label: 'results.time'.tr(),
                    value: formatDuration(result.timeTakenSeconds),
                    icon: PhosphorIconsFill.timer,
                    color: const Color(0xFF0EA5E9),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (result.passed) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFD97706).withValues(alpha: 0.35),
                  ),
                  onPressed: () {
                    ExamCertificateDialog.show(context, result);
                  },
                  icon: const Icon(PhosphorIconsFill.certificate, size: 20),
                  label: Text(
                    'View Readiness Certificate',
                    style: AppFonts.outfit(
                      context,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 4,
                  shadowColor: ModernTheme.primary.withValues(alpha: 0.35),
                ),
                onPressed: () {
                  AppFeedback.tap(context);
                  context.pushReplacement('/exam');
                },
                child: Text(
                  'exam.tryAgain'.tr(),
                  style: AppFonts.outfit(
                    context,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _HeroScore extends StatelessWidget {
  const _HeroScore({required this.result});
  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = passed ? ModernTheme.emerald : ModernTheme.coral;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : scheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
              color: color,
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              passed ? 'results.passed'.tr() : 'results.failed'.tr(),
              style: AppFonts.outfit(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${result.scorePercentage.toStringAsFixed(0)}%',
            style: AppFonts.outfit(
              context,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCorrectAnswers(
                context, result.correctAnswers, result.totalQuestions),
            style: AppFonts.outfit(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _StatSmallCard extends StatelessWidget {
  const _StatSmallCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.55),
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
