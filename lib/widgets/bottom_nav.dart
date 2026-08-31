import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/app_fonts.dart';
import 'glass_container.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(
        icon: PhosphorIconsRegular.house,
        activeIcon: PhosphorIconsFill.house,
        label: 'nav.home'.tr(),
      ),
      _NavItem(
        icon: PhosphorIconsRegular.trafficSign,
        activeIcon: PhosphorIconsFill.trafficSign,
        label: 'nav.signs'.tr(),
      ),
      _NavItem(
        icon: PhosphorIconsRegular.gear,
        activeIcon: PhosphorIconsFill.gear,
        label: 'nav.settings'.tr(),
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(28),
          blur: 16,
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.92),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : scheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!selected) {
                          AppFeedback.tap(context);
                        }
                        onTap(index);
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? ModernTheme.primary
                                  .withValues(alpha: isDark ? 0.22 : 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: selected
                              ? Border.all(
                                  color: ModernTheme.primary
                                      .withValues(alpha: isDark ? 0.35 : 0.25),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutBack,
                              scale: selected ? 1.15 : 1.0,
                              child: Icon(
                                selected ? item.activeIcon : item.icon,
                                color: selected
                                    ? ModernTheme.primary
                                    : scheme.onSurface
                                        .withValues(alpha: isDark ? 0.55 : 0.65),
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppFonts.outfit(
                                context,
                                color: selected
                                    ? ModernTheme.primary
                                    : scheme.onSurface
                                        .withValues(alpha: isDark ? 0.55 : 0.65),
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 11,
                              ),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
