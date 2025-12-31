import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/signs')) index = 1;
    if (location.startsWith('/practice')) index = 2;
    if (location.startsWith('/exam')) index = 3;
    if (location.startsWith('/settings')) index = 4;

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (idx) {
        switch (idx) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/signs');
            break;
          case 2:
            context.go('/practice');
            break;
          case 3:
            context.go('/exam');
            break;
          case 4:
            context.go('/settings');
            break;
        }
      },
      destinations: [
        NavigationDestination(icon: const Icon(Icons.home_outlined), label: 'nav.home'.tr()),
        NavigationDestination(icon: const Icon(Icons.book_outlined), label: 'nav.signs'.tr()),
        NavigationDestination(icon: const Icon(Icons.help_outline), label: 'nav.practice'.tr()),
        NavigationDestination(icon: const Icon(Icons.school_outlined), label: 'nav.exam'.tr()),
        NavigationDestination(icon: const Icon(Icons.settings_outlined), label: 'nav.settings'.tr()),
      ],
    );
  }
}
