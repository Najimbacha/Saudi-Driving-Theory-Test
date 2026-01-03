import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
    final isDark = scheme.brightness == Brightness.dark;
    final items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'nav.home'.tr(),
      ),
      _NavItem(
        icon: Icons.book_rounded,
        label: 'nav.signs'.tr(),
      ),
      _NavItem(
        icon: Icons.quiz_outlined,
        label: 'nav.practice'.tr(),
      ),
      _NavItem(
        icon: Icons.school_rounded,
        label: 'nav.exam'.tr(),
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: 'nav.settings'.tr(),
      ),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? scheme.surfaceContainerHighest
              : scheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
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
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? scheme.primaryContainer.withValues(alpha: isDark ? 1 : 0.8)
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
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 11,
                                  letterSpacing: 0.2,
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

