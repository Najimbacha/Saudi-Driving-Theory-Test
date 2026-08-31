import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            _GridItem(
              icon: PhosphorIconsFill.circlesFour,
              title: 'home.practiceByCategory'.tr(),
              subtitle: 'home.practiceByCategoryDesc'.tr(),
              color: const Color(0xFF6366F1),
              onTap: onTapCategories ?? onTapHandbook,
            ),
            _GridItem(
              icon: PhosphorIconsFill.trafficSign,
              title: 'home.learnSigns'.tr(),
              subtitle: 'home.learnSignsDesc'.tr(),
              color: const Color(0xFF0EA5E9),
              onTap: onTapSigns,
            ),
            _GridItem(
              icon: PhosphorIconsFill.chartBar,
              title: 'home.stats'.tr(),
              subtitle: 'home.statsDesc'.tr(),
              color: const Color(0xFF8B5CF6),
              onTap: onTapStats,
            ),
            _GridItem(
              icon: PhosphorIconsFill.clockCounterClockwise,
              title: 'home.history'.tr(),
              subtitle: 'home.historyDesc'.tr(),
              color: const Color(0xFFF59E0B),
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : scheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
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
                    Text(
                      title,
                      style: AppFonts.outfit(
                        context,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.outfit(
                        context,
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
