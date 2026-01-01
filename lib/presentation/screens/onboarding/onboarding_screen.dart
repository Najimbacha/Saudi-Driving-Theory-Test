import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.traffic_outlined,
      titleKey: 'home.learnSigns',
      subtitleKey: 'home.learnSignsDesc',
    ),
    _OnboardingPage(
      icon: Icons.quiz_outlined,
      titleKey: 'home.practice',
      subtitleKey: 'home.practiceDesc',
      bullets: [
        'quiz.selectCategory',
        'quiz.start',
      ],
    ),
    _OnboardingPage(
      icon: Icons.assignment_outlined,
      titleKey: 'home.mockExam',
      subtitleKey: 'home.mockExamDesc',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _complete() {
    final prefs = ref.read(sharedPrefsProvider);
    prefs.setString('hasSeenOnboarding', 'true');
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _complete,
            child: Text('common.skip'.tr()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (value) => setState(() => _currentIndex = value),
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(page.icon, size: 56, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        page.titleKey.tr(),
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.subtitleKey.tr(),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        textAlign: TextAlign.center,
                      ),
                      if (page.bullets.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Column(
                          children: page.bullets.map((bullet) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    bullet.tr(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                width: _currentIndex == index ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ElevatedButton(
                  key: ValueKey(_currentIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentIndex == _pages.length - 1 ? AppColors.secondary : AppColors.primary,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    if (_currentIndex == _pages.length - 1) {
                      _complete();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentIndex == _pages.length - 1 ? 'onboarding.getStarted'.tr() : 'common.next'.tr(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    this.bullets = const [],
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final List<String> bullets;
}
