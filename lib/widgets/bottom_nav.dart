import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/modern_theme.dart';
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
      child: GlassContainer(
        margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        borderRadius: BorderRadius.circular(28),
        blur: 20,
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
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
                            ? ModernTheme.primary.withValues(alpha: 0.15)
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
                                  : Colors.white.withValues(alpha: 0.5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.outfit(
                              color: selected
                                  ? ModernTheme.primary
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
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
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
