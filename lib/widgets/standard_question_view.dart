import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/modern_theme.dart';
import '../../utils/app_fonts.dart';

/// A beautiful, standard question block used across practice, exam and
/// module quizzes for a consistent look and feel.
class StandardQuestionView extends StatelessWidget {
  const StandardQuestionView({
    super.key,
    required this.questionText,
    required this.optionTexts,
    required this.selectedIndex,
    this.correctIndex,
    this.revealed = false,
    this.signPath,
    this.optionBuilder,
    this.onSelect,
  });

  final String questionText;
  final List<String> optionTexts;

  /// The currently selected option index (or null).
  final int? selectedIndex;

  /// The correct option index (used when [revealed] is true).
  final int? correctIndex;

  /// Whether the correct answer has been revealed.
  final bool revealed;

  /// Optional sign SVG asset path (e.g. `ksa-signs/x.svg`).
  final String? signPath;

  /// Optional custom trailing widget per option (e.g. check icons).
  final Widget Function(BuildContext context, int index, bool isSelected)? optionBuilder;

  final void Function(int index)? onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question card
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : scheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                questionText,
                style: AppFonts.outfit(context,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: scheme.onSurface),
              ),
              if (signPath != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      'assets/$signPath',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Options
        ...List.generate(optionTexts.length, (idx) {
          final isSelected = selectedIndex == idx;
          final isCorrect = revealed && correctIndex == idx;
          final isWrong = revealed && isSelected && correctIndex != idx;
          final canTap = onSelect != null;

          Color borderColor = scheme.onSurface.withValues(alpha: 0.1);
          Color bg = isDark
              ? Colors.white.withValues(alpha: 0.02)
              : scheme.surface;
          Color badgeBg = scheme.onSurface.withValues(alpha: 0.06);
          Color badgeFg = scheme.onSurface.withValues(alpha: 0.6);
          Color textColor = scheme.onSurface.withValues(alpha: 0.85);

          if (isSelected && !revealed) {
            borderColor = scheme.primary;
            bg = scheme.primary.withValues(alpha: 0.08);
            badgeBg = scheme.primary;
            badgeFg = Colors.white;
            textColor = scheme.onSurface;
          } else if (isCorrect) {
            borderColor = ModernTheme.emerald;
            bg = ModernTheme.emerald.withValues(alpha: 0.12);
            badgeBg = ModernTheme.emerald;
            badgeFg = Colors.white;
            textColor = scheme.onSurface;
          } else if (isWrong) {
            borderColor = scheme.error;
            bg = scheme.error.withValues(alpha: 0.1);
            badgeBg = scheme.error;
            badgeFg = Colors.white;
            textColor = scheme.onSurface;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: canTap ? () => onSelect!(idx) : null,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected || isCorrect || isWrong ? 1.8 : 1.2,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isCorrect
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : isWrong
                              ? const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.white)
                              : Text(
                                  String.fromCharCode(65 + idx),
                                  style: AppFonts.outfit(context,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: badgeFg),
                                ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionTexts[idx],
                        style: AppFonts.outfit(context,
                            fontSize: 14.5,
                            height: 1.3,
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
                      ),
                    ),
                    if (optionBuilder != null)
                      optionBuilder!(context, idx, isSelected),
                    if (isSelected && !revealed && optionBuilder == null)
                      Icon(Icons.check_circle_rounded,
                          color: scheme.primary, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
