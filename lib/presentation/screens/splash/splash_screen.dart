import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../state/app_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _loopController;
  late final Animation<Offset> _carSlide;
  late final Animation<double> _carScale;
  late final Animation<double> _laneShift;
  late final Animation<double> _headlightPulse;
  bool _navigated = false;
  static const String _appNameFallback = 'Saudi Driving Theory Test';

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _carSlide = Tween<Offset>(
      begin: const Offset(-0.7, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _carScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.4, 0.95, curve: Curves.easeOutBack),
      ),
    );
    _laneShift = CurvedAnimation(parent: _loopController, curve: Curves.linear);
    _headlightPulse =
        CurvedAnimation(parent: _loopController, curve: Curves.easeInOut);

    _introController.forward();
    Future<void>.delayed(const Duration(milliseconds: 2300), _handleNavigation);
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  void _handleNavigation() {
    if (!mounted || _navigated) return;
    _navigated = true;
    final prefs = ref.read(sharedPrefsProvider);
    final hasSeenOnboarding = prefs.getString('hasSeenOnboarding') == 'true';
    context.go(hasSeenOnboarding ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final size = media.size;
    final shortest = size.shortestSide;
    final carWidth = (shortest * 0.7).clamp(220.0, 360.0);
    final roadHeight = (size.height * 0.32).clamp(180.0, 280.0);

    final bgTop = isDark ? const Color(0xFF06130C) : const Color(0xFFE6F7EC);
    final bgBottom = isDark ? const Color(0xFF0B1020) : const Color(0xFFF8FBFF);
    final glow = isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);
    final appName =
        trExists('app.name') ? tr('app.name') : _appNameFallback;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Semantics(
          label: appName,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgTop, bgBottom],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -80,
                  child: _GlowOrb(color: glow, size: 240),
                ),
                Positioned(
                  bottom: -120,
                  left: -60,
                  child:
                      _GlowOrb(color: glow.withValues(alpha: 0.6), size: 220),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: roadHeight,
                    child: _RoadLanes(
                      animation: _laneShift,
                      isDark: isDark,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_introController, _loopController]),
                    builder: (context, _) {
                      final pulse = 0.4 +
                          0.6 * (0.5 + 0.5 * sin(_headlightPulse.value * pi));
                      return SlideTransition(
                        position: _carSlide,
                        child: ScaleTransition(
                          scale: _carScale,
                          child: _CarIllustration(
                            width: carWidth,
                            glowOpacity: pulse,
                            scheme: scheme,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.3), Colors.transparent],
        ),
      ),
    );
  }
}

class _RoadLanes extends StatelessWidget {
  const _RoadLanes({required this.animation, required this.isDark});

  final Animation<double> animation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final laneColor = isDark
            ? Colors.white.withValues(alpha: 0.6)
            : scheme.onSurface.withValues(alpha: 0.35);
        final roadColor = isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.85)
            : const Color(0xFFE5E7EB);
        final shift = animation.value * 32;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              Container(color: roadColor),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, shift),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      8,
                      (index) => Center(
                        child: Container(
                          width: 6,
                          height: 22,
                          decoration: BoxDecoration(
                            color: laneColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarIllustration extends StatelessWidget {
  const _CarIllustration({
    required this.width,
    required this.glowOpacity,
    required this.scheme,
    required this.isDark,
  });

  final double width;
  final double glowOpacity;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.52;
    final bodyColor =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1F2937);
    final trimColor =
        isDark ? const Color(0xFFCBD5F5) : const Color(0xFF0F172A);
    final wheelColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFF111827);
    final glowColor = const Color(0xFFFACC15).withValues(alpha: glowOpacity);

    return Semantics(
      label: 'onboarding.practiceTitle'.tr(),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: height * 0.1,
              left: width * 0.12,
              right: width * 0.12,
              child: Container(
                height: height * 0.46,
                decoration: BoxDecoration(
                  color: bodyColor,
                  borderRadius: BorderRadius.circular(height * 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.32,
              left: width * 0.22,
              right: width * 0.22,
              child: Container(
                height: height * 0.28,
                decoration: BoxDecoration(
                  color: trimColor,
                  borderRadius: BorderRadius.circular(height * 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: height * 0.12,
              left: width * 0.18,
              child: _Wheel(color: wheelColor, size: width * 0.18),
            ),
            Positioned(
              bottom: height * 0.12,
              right: width * 0.18,
              child: _Wheel(color: wheelColor, size: width * 0.18),
            ),
            Positioned(
              bottom: height * 0.28,
              left: width * 0.08,
              child: _Headlight(glow: glowColor, isDark: isDark),
            ),
            Positioned(
              bottom: height * 0.28,
              right: width * 0.08,
              child: _Headlight(glow: glowColor, isDark: isDark),
            ),
            Positioned(
              bottom: height * 0.26,
              left: width * 0.32,
              right: width * 0.32,
              child: Container(
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Headlight extends StatelessWidget {
  const _Headlight({required this.glow, required this.isDark});

  final Color glow;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 12,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: glow,
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
