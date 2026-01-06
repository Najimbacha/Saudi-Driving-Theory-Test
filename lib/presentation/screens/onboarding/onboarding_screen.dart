import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../state/app_state.dart';

class OnboardingIntroScreen extends ConsumerStatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  ConsumerState<OnboardingIntroScreen> createState() =>
      _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends ConsumerState<OnboardingIntroScreen>
    with TickerProviderStateMixin {
  late final PageController _controller;
  late final AnimationController _pulseController;
  int _currentIndex = 0;
  bool _isCompleting = false;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      titleKey: 'onboarding.practiceTitle',
      descriptionKey: 'onboarding.practiceDesc',
      type: _OnboardingArtType.practice,
    ),
    _OnboardingPageData(
      titleKey: 'onboarding.examTitle',
      descriptionKey: 'onboarding.examDesc',
      type: _OnboardingArtType.exam,
    ),
    _OnboardingPageData(
      titleKey: 'onboarding.offlineTitle',
      descriptionKey: 'onboarding.offlineDesc2',
      type: _OnboardingArtType.offline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _redirectIfCompleted();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _redirectIfCompleted() {
    final prefs = ref.read(sharedPrefsProvider);
    final hasSeenOnboarding = prefs.getString('hasSeenOnboarding') == 'true';
    if (!hasSeenOnboarding) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/home');
    });
  }

  void _complete() {
    if (_isCompleting) return;
    _isCompleting = true;
    final prefs = ref.read(sharedPrefsProvider);
    prefs.setString('hasSeenOnboarding', 'true');
    context.go('/home');
  }

  Future<void> _handleBack() async {
    if (_currentIndex > 0) {
      await _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScaler = media.textScaler.clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.15,
    );

    return MediaQuery(
      data: media.copyWith(textScaler: textScaler),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleBack();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _complete,
                      child: Text('common.skip'.tr()),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (value) =>
                        setState(() => _currentIndex = value),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final pageOffset = _controller.hasClients
                              ? (_controller.page ?? _currentIndex) - index
                              : 0.0;
                          final scale =
                              (1 - pageOffset.abs() * 0.08).clamp(0.92, 1.0);
                          final opacity =
                              (1 - pageOffset.abs() * 0.4).clamp(0.4, 1.0);
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: _OnboardingPage(
                          data: page,
                          pulse: _pulseController,
                        ),
                      );
                    },
                  ),
                ),
                _OnboardingFooter(
                  currentIndex: _currentIndex,
                  total: _pages.length,
                  onNext: () {
                    HapticFeedback.selectionClick();
                    if (_currentIndex == _pages.length - 1) {
                      _complete();
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  nextLabel: _currentIndex == _pages.length - 1
                      ? 'onboarding.getStarted'.tr()
                      : 'common.next'.tr(),
                ),
                SizedBox(height: media.padding.bottom > 0 ? 0 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.pulse,
  });

  final _OnboardingPageData data;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: data.titleKey.tr(),
            child: _IllustrationCard(
              type: data.type,
              pulse: pulse,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            data.titleKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            data.descriptionKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.nextLabel,
  });

  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? AppColors.primary
                      : scheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
              ),
              onPressed: onNext,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({
    required this.type,
    required this.pulse,
    required this.isDark,
  });

  final _OnboardingArtType type;
  final Animation<double> pulse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = isDark
        ? scheme.surface.withValues(alpha: 0.3)
        : scheme.surface.withValues(alpha: 0.95);

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final value = 0.5 + 0.5 * sin(pulse.value * pi);
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: _IllustrationContent(type: type, value: value),
          ),
        );
      },
    );
  }
}

class _IllustrationContent extends StatelessWidget {
  const _IllustrationContent({
    required this.type,
    required this.value,
  });

  final _OnboardingArtType type;
  final double value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = AppColors.primary;
    final secondary = AppColors.secondary;

    switch (type) {
      case _OnboardingArtType.practice:
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: (value - 0.5) * 0.2,
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 120,
                color: primary.withValues(alpha: 0.9),
              ),
            ),
            Positioned(
              bottom: 56,
              child: Transform.scale(
                scale: 0.9 + value * 0.1,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: secondary,
                ),
              ),
            ),
          ],
        );
      case _OnboardingArtType.exam:
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(140, 140),
              painter: _ProgressRingPainter(
                value: 0.6 + value * 0.3,
                color: secondary,
                track: scheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
            Icon(
              Icons.timer_rounded,
              size: 72,
              color: primary,
            ),
          ],
        );
      case _OnboardingArtType.offline:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.language_rounded,
              size: 110,
              color: primary,
            ),
            Positioned(
              top: 56,
              left: 60,
              child: _PulseDot(size: 16, color: secondary, value: value),
            ),
            Positioned(
              top: 80,
              right: 64,
              child: _PulseDot(size: 12, color: primary, value: value),
            ),
            Positioned(
              bottom: 64,
              child:
                  _PulseDot(size: 18, color: AppColors.tertiary, value: value),
            ),
          ],
        );
    }
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({
    required this.size,
    required this.color,
    required this.value,
  });

  final double size;
  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + value * 6,
      height: size + value * 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.value,
    required this.color,
    required this.track,
  });

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final stroke = 10.0;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(center, radius, trackPaint);
    final sweep = (2 * pi) * value.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.track != track;
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.titleKey,
    required this.descriptionKey,
    required this.type,
  });

  final String titleKey;
  final String descriptionKey;
  final _OnboardingArtType type;
}

enum _OnboardingArtType { practice, exam, offline }
