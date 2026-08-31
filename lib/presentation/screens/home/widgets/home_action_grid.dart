import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/modern_theme.dart';
import '../../../../utils/app_fonts.dart';

class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({
    super.key,
    required this.onTapHandbook,
    required this.onTapSigns,
    required this.onTapStats,
    required this.onTapHistory,
    this.onTapCategories,
    this.onTapViolations,
  });

  final VoidCallback onTapHandbook;
  final VoidCallback onTapSigns;
  final VoidCallback onTapStats;
  final VoidCallback onTapHistory;
  final VoidCallback? onTapCategories;
  final VoidCallback? onTapViolations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // Fixed tile height (not width-dependent) so content never overflows
          // on any screen size.
          mainAxisExtent: 148,
          children: [
            _GridItem(
              icon: PhosphorIconsFill.circlesFour,
              title: 'home.practiceByCategory'.tr(),
              subtitle: 'home.practiceByCategoryDesc'.tr(),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: onTapCategories ?? onTapHandbook,
            ),
            _GridItem(
              icon: PhosphorIconsFill.trafficSign,
              title: 'home.learnSigns'.tr(),
              subtitle: 'home.learnSignsDesc'.tr(),
              gradient: ModernTheme.electricCyanGradient,
              onTap: onTapSigns,
            ),
            _GridItem(
              icon: PhosphorIconsFill.chartBar,
              title: 'home.stats'.tr(),
              subtitle: 'home.statsDesc'.tr(),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: onTapStats,
            ),
            _GridItem(
              icon: PhosphorIconsFill.clockCounterClockwise,
              title: 'home.history'.tr(),
              subtitle: 'home.historyDesc'.tr(),
              gradient: ModernTheme.goldMetallicGradient,
              onTap: onTapHistory,
            ),
          ],
        ),
      ],
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.85)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: AppFonts.outfit(
                      context,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: scheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppFonts.outfit(
                      context,
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
