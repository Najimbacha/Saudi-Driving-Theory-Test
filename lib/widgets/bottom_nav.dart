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
        icon: Icons.help_rounded,
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
        margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
        padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: scheme.brightness == Brightness.dark ? 0.92 : 0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary.withValues(alpha: scheme.brightness == Brightness.dark ? 0.18 : 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.05 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            item.icon,
                            color: selected
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.55),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: selected
                                    ? scheme.primary
                                    : scheme.onSurface.withValues(alpha: 0.55),
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 12,
                              ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
