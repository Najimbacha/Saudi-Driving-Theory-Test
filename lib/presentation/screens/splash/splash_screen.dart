import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final Animation<Offset> _emblemSlide;
  late final Animation<double> _emblemScale;
  late final Animation<double> _laneShift;
  late final Animation<double> _pulse;
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

    _emblemSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _emblemScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 0.95, curve: Curves.easeOutBack),
      ),
    );
    _laneShift = CurvedAnimation(parent: _loopController, curve: Curves.linear);
    _pulse = CurvedAnimation(parent: _loopController, curve: Curves.easeInOut);

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
    final emblemSize = (shortest * 0.56).clamp(190.0, 300.0);
    final roadHeight = (size.height * 0.26).clamp(150.0, 220.0);

    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFF2F7FF);
    final bgBottom = isDark ? const Color(0xFF070B14) : const Color(0xFFE8F1FF);
    final glowA = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
    final glowB = isDark ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9);
    final appName =
        trExists('app.name') ? tr('app.name') : _appNameFallback;
    final tagline = trExists('app.tagline') ? tr('app.tagline') : '';

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
                  child: _GlowOrb(color: glowA, size: 260),
                ),
                Positioned(
                  bottom: -120,
                  left: -60,
                  child:
                      _GlowOrb(color: glowB.withValues(alpha: 0.7), size: 240),
                ),
                Positioned(
                  top: size.height * 0.12,
                  left: -80,
                  child:
                      _GlowOrb(color: glowA.withValues(alpha: 0.5), size: 180),
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
                      final pulse =
                          0.35 + 0.65 * (0.5 + 0.5 * sin(_pulse.value * pi));
                      final spin = _loopController.value * pi * 2;
                      return SlideTransition(
                        position: _emblemSlide,
                        child: ScaleTransition(
                          scale: _emblemScale,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SplashEmblem(
                                  size: emblemSize,
                                  glowOpacity: pulse,
                                  spin: spin,
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  appName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.syne(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                if (tagline.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    tagline,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
        final roadTop = isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.85)
            : const Color(0xFFE2E8F0);
        final roadBottom = isDark
            ? const Color(0xFF111827).withValues(alpha: 0.95)
            : const Color(0xFFF8FAFC);
        final shift = animation.value * 32;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [roadTop, roadBottom],
                  ),
                ),
              ),
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

class _SplashEmblem extends StatelessWidget {
  const _SplashEmblem({
    required this.size,
    required this.glowOpacity,
    required this.spin,
    required this.isDark,
  });

  final double size;
  final double glowOpacity;
  final double spin;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ringColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF1D4ED8);
    final accentColor =
        isDark ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9);
    final innerColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final softGlow =
        ringColor.withValues(alpha: 0.12 + glowOpacity * 0.28);
    final warmGlow =
        accentColor.withValues(alpha: 0.1 + glowOpacity * 0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: softGlow, blurRadius: 42, spreadRadius: 6),
                BoxShadow(color: warmGlow, blurRadius: 60, spreadRadius: 10),
              ],
            ),
          ),
          Transform.rotate(
            angle: spin,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    ringColor.withValues(alpha: 0.08),
                    ringColor.withValues(alpha: 0.6),
                    accentColor.withValues(alpha: 0.4),
                    ringColor.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: size * 0.76,
            height: size * 0.76,
            decoration: BoxDecoration(
              color: innerColor,
              shape: BoxShape.circle,
              border:
                  Border.all(color: ringColor.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.54,
            height: size * 0.54,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              shape: BoxShape.circle,
              border:
                  Border.all(color: ringColor.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: accentColor,
              size: size * 0.24,
            ),
          ),
          Positioned(
            top: size * 0.1,
            child: _EmblemDot(color: accentColor, size: size * 0.06),
          ),
          Positioned(
            right: size * 0.14,
            top: size * 0.62,
            child: _EmblemDot(
                color: ringColor.withValues(alpha: 0.8), size: size * 0.05),
          ),
          Positioned(
            left: size * 0.18,
            bottom: size * 0.18,
            child: _EmblemDot(
                color: ringColor.withValues(alpha: 0.7), size: size * 0.04),
          ),
        ],
      ),
    );
  }
}

class _EmblemDot extends StatelessWidget {
  const _EmblemDot({required this.color, required this.size});

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
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
