import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/theme/modern_theme.dart';
import '../utils/app_feedback.dart';
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
        label: 'nav.home'.tr(),
      ),
      _NavItem(
        icon: PhosphorIconsRegular.trafficSign,
        label: 'nav.signs'.tr(),
      ),
      _NavItem(
        icon: PhosphorIconsRegular.gear,
        label: 'nav.settings'.tr(),
      ),
    ];

    return SafeArea(
      top: false,
      child: GlassContainer(
        margin: EdgeInsetsDirectional.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        borderRadius: BorderRadius.circular(28),
        blur: 20,
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.8)
            : scheme.surface.withValues(alpha: 0.95),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : scheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? ModernTheme.primary
                                .withValues(alpha: isDark ? 0.15 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOutCubic,
                            scale: selected ? 1.1 : 1.0,
                            child: Icon(
                              item.icon,
                              color: selected
                                  ? ModernTheme.primary
                                  : scheme.onSurface
                                      .withValues(alpha: isDark ? 0.6 : 0.75),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.outfit(
                              color: selected
                                  ? ModernTheme.primary
                                  : scheme.onSurface
                                      .withValues(alpha: isDark ? 0.6 : 0.75),
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 10,
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
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
