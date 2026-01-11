import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/modern_theme.dart';
import '../../../utils/app_fonts.dart';
import '../../../widgets/glass_container.dart';
import '../../providers/exam_history_provider.dart';

class ExamHistoryScreen extends ConsumerWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(examHistoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'history.title'.tr(),
          style: AppFonts.outfit(
            context,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? ModernTheme.darkGradient : ModernTheme.lightGradient,
        ),
        child: SafeArea(
          child: history.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    blur: isDark ? 12 : 6,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.9),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: scheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'history.empty'.tr(),
                          style: AppFonts.outfit(
                            context,
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  cacheExtent: 800,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final result = history[index];
                    final score = result.scorePercentage.toStringAsFixed(0);
                    return _HistoryCard(
                      title:
                          '${'history.examTypes.${result.examType}'.tr()} • $score%',
                      subtitle:
                          DateFormat.yMMMd().add_jm().format(result.dateTime),
                      passed: result.passed,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.passed,
  });

  final String title;
  final String subtitle;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = passed ? AppColors.success : AppColors.error;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      blur: isDark ? 10 : 6,
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.9),
      border: Border.all(color: scheme.onSurface.withValues(alpha: 0.08)),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              passed ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.outfit(
                    context,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppFonts.outfit(
                    context,
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.6),
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
