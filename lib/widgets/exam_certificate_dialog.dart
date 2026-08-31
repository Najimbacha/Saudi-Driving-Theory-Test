import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../data/models/exam_result_model.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import '../utils/app_toast.dart';

class ExamCertificateDialog extends StatelessWidget {
  const ExamCertificateDialog({super.key, required this.result});

  final ExamResult result;

  static void show(BuildContext context, ExamResult result) {
    AppFeedback.confirm(context);
    showDialog(
      context: context,
      builder: (context) => ExamCertificateDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('MMMM d, yyyy').format(result.dateTime);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold Seal Emblem
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: ModernTheme.goldMetallicGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF59E0B),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  PhosphorIconsFill.sealCheck,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'CERTIFICATE OF READINESS',
              style: AppFonts.outfit(
                context,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: const Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saudi Driving Theory Test',
              textAlign: TextAlign.center,
              style: AppFonts.outfit(
                context,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ModernTheme.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ModernTheme.emerald.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${result.scorePercentage.toStringAsFixed(0)}%',
                        style: AppFonts.outfit(
                          context,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: ModernTheme.emerald,
                        ),
                      ),
                      Text(
                        'FINAL SCORE',
                        style: AppFonts.outfit(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: scheme.onSurface.withValues(alpha: 0.15),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.correctAnswers}/${result.totalQuestions}',
                        style: AppFonts.outfit(
                          context,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        'CORRECT',
                        style: AppFonts.outfit(
                          context,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Issued on $formattedDate',
              style: AppFonts.outfit(
                context,
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'common.close'.tr(),
                      style: AppFonts.outfit(
                        context,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      AppFeedback.confirm(context);
                      Navigator.pop(context);
                      showAppToast(
                        context,
                        'results.certificateShared'.tr(),
                        success: true,
                      );
                    },
                    icon: const Icon(PhosphorIconsFill.shareNetwork, size: 18),
                    label: Text(
                      'Share',
                      style: AppFonts.outfit(
                        context,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
