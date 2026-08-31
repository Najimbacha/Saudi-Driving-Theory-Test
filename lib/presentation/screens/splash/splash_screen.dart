import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../state/app_state.dart';
import '../../../utils/navigation_utils.dart';

/// Minimalist premium splash: a stylized 3D-looking car floats over a soft
/// gradient with gentle glow orbs and a shimmering progress line.
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
  late final Animation<double> _fade;
  late final Animation<double> _bob;
  bool _navigated = false;
  static const String _appNameFallback = 'Saudi Driving Theory Test';

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _carSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _carScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.15, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _fade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
    );
    _bob = CurvedAnimation(parent: _loopController, curve: Curves.easeInOut);

    _introController.forward();
    Future<void>.delayed(const Duration(milliseconds: 2200), _handleNavigation);
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
    final carWidth = (shortest * 0.78).clamp(280.0, 420.0);
    final carHeight = carWidth * 0.46;

    final bgTop = isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F8FF);
    final bgBottom = isDark ? const Color(0xFF06090F) : const Color(0xFFE9F0FF);
    final glowA = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
    final glowB = isDark ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9);
    final appName =
        trExists('app.name') ? tr('app.name') : _appNameFallback;
    final tagline = trExists('app.tagline') ? tr('app.tagline') : '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await handleAppBack(context, fromPopScope: true);
      },
      child: Scaffold(
        body: Semantics(
          label: appName,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBottom],
              ),
            ),
            child: Stack(
              children: [
                // Soft ambient glow orbs
                Positioned(
                  top: -140,
                  right: -90,
                  child: _GlowOrb(color: glowA, size: 300),
                ),
                Positioned(
                  bottom: -160,
                  left: -80,
                  child:
                      _GlowOrb(color: glowB.withValues(alpha: 0.55), size: 280),
                ),
                Positioned(
                  top: size.height * 0.3,
                  left: -100,
                  child:
                      _GlowOrb(color: glowA.withValues(alpha: 0.4), size: 200),
                ),

                // Center content
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_introController, _loopController]),
                  builder: (context, _) {
                    final bobOffset = sin(_bob.value * 2 * pi) * 5;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SlideTransition(
                            position: _carSlide,
                            child: ScaleTransition(
                              scale: _carScale,
                              child: Transform.translate(
                                offset: Offset(0, bobOffset),
                                child: _FloatingCar(
                                  width: carWidth,
                                  height: carHeight,
                                  isDark: isDark,
                                  bobPhase: _bob.value,
                                ),
                              ),
                            ),
                          ),
                          FadeTransition(
                            opacity: _fade,
                            child: Column(
                              children: [
                                const SizedBox(height: 18),
                                Text(
                                  appName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.syne(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                    letterSpacing: -0.5,
                                    height: 1.15,
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
                                          .withValues(alpha: 0.65),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 26),
                                _ProgressLine(
                                  animation: _loopController,
                                  color: glowA,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
          colors: [color.withValues(alpha: 0.28), Colors.transparent],
        ),
      ),
    );
  }
}

/// A shimmering horizontal progress line that loops.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        return SizedBox(
          width: 160,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                Container(color: color.withValues(alpha: 0.15)),
                Align(
                  alignment: Alignment(progress * 2 - 1, 0),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0),
                          color,
                          color.withValues(alpha: 0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A stylized 3D-looking car drawn with layered gradients and reflections.
class _FloatingCar extends StatelessWidget {
  const _FloatingCar({
    required this.width,
    required this.height,
    required this.isDark,
    required this.bobPhase,
  });

  final double width;
  final double height;
  final bool isDark;
  final double bobPhase;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 30,
      child: CustomPaint(
        painter: _CarPainter(isDark: isDark, bobPhase: bobPhase),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  _CarPainter({required this.isDark, required this.bobPhase});

  final bool isDark;
  final double bobPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.94;

    // Ground shadow (soft ellipse under the car)
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(w / 2, groundY),
        radius: w * 0.42,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, groundY),
        width: w * 0.78,
        height: h * 0.14,
      ),
      shadowPaint,
    );

    // --- Wheels ---
    final wheelRadius = w * 0.11;
    final wheelY = groundY - wheelRadius * 0.35;
    _drawWheel(canvas, Offset(w * 0.24, wheelY), wheelRadius, isDark);
    _drawWheel(canvas, Offset(w * 0.76, wheelY), wheelRadius, isDark);

    // --- Body ---
    final bodyPath = Path()
      ..moveTo(w * 0.06, h * 0.62)
      // rear bumper
      ..cubicTo(w * 0.02, h * 0.55, w * 0.03, h * 0.42, w * 0.1, h * 0.36)
      // trunk
      ..cubicTo(w * 0.17, h * 0.31, w * 0.25, h * 0.3, w * 0.33, h * 0.27)
      // cabin base -> roof
      ..cubicTo(w * 0.4, h * 0.2, w * 0.45, h * 0.08, w * 0.56, h * 0.08)
      // windshield -> hood
      ..cubicTo(w * 0.66, h * 0.08, w * 0.72, h * 0.16, w * 0.78, h * 0.22)
      // hood -> front
      ..cubicTo(w * 0.84, h * 0.26, w * 0.92, h * 0.28, w * 0.95, h * 0.36)
      ..cubicTo(w * 0.985, h * 0.44, w * 0.98, h * 0.54, w * 0.92, h * 0.6)
      // front lower -> rear wheel arch
      ..lineTo(w * 0.88, h * 0.64)
      ..quadraticBezierTo(w * 0.84, h * 0.8, w * 0.68, h * 0.8)
      // floor
      ..lineTo(w * 0.32, h * 0.8)
      // rear wheel arch -> rear
      ..quadraticBezierTo(w * 0.16, h * 0.8, w * 0.12, h * 0.64)
      ..close();

    final bodyTop = isDark ? const Color(0xFF4F8EF7) : const Color(0xFF6EA8FF);
    final bodyBottom =
        isDark ? const Color(0xFF233A66) : const Color(0xFF3E7AE8);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bodyTop, bodyBottom],
      ).createShader(Rect.fromLTWH(0, h * 0.05, w, h * 0.8));
    canvas.drawPath(bodyPath, bodyPaint);

    // Body outline for definition
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
    );

    // Glass cabin (with tint + reflection)
    final glass = Path()
      ..moveTo(w * 0.36, h * 0.28)
      ..quadraticBezierTo(w * 0.42, h * 0.14, w * 0.54, h * 0.14)
      ..quadraticBezierTo(w * 0.63, h * 0.14, w * 0.68, h * 0.24)
      ..lineTo(w * 0.61, h * 0.29)
      ..quadraticBezierTo(w * 0.5, h * 0.34, w * 0.41, h * 0.33)
      ..close();
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          if (isDark) const Color(0xFF0A1630) else const Color(0xFFDDEBFF),
          if (isDark) const Color(0xFF16345F) else const Color(0xFF8FB8F5),
        ],
      ).createShader(Rect.fromLTWH(w * 0.36, h * 0.1, w * 0.34, h * 0.28));
    canvas.drawPath(glass, glassPaint);

    // Glass diagonal highlight
    canvas.drawLine(
      Offset(w * 0.4, h * 0.3),
      Offset(w * 0.56, h * 0.16),
      Paint()
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.5),
    );

    // Hood highlight
    canvas.drawLine(
      Offset(w * 0.72, h * 0.26),
      Offset(w * 0.9, h * 0.34),
      Paint()
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: isDark ? 0.18 : 0.6),
    );

    // Chrome belt line
    canvas.drawLine(
      Offset(w * 0.14, h * 0.36),
      Offset(w * 0.86, h * 0.4),
      Paint()
        ..strokeWidth = w * 0.012
        ..color = Colors.white.withValues(alpha: isDark ? 0.25 : 0.7),
    );

    // Headlight + beam
    final headX = w * 0.93;
    final headY = h * 0.4;
    canvas.drawCircle(
      Offset(headX - w * 0.01, headY),
      w * 0.03,
      Paint()..color = const Color(0xFFFFE9A8),
    );
    final beam = Path()
      ..moveTo(headX, headY - w * 0.02)
      ..lineTo(w, headY - h * 0.16)
      ..lineTo(w, headY + h * 0.12)
      ..lineTo(headX, headY + w * 0.02)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFFE9A8).withValues(alpha: isDark ? 0.35 : 0.22),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(headX, headY - h * 0.18, w - headX, h * 0.36)),
    );

    // Taillight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.055, h * 0.34, w * 0.035, h * 0.08),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFF4D4D),
    );
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, bool isDark) {
    // Tire
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            if (isDark) const Color(0xFF2A2F3A) else const Color(0xFF3A3F4A),
            Colors.black,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    // Rim
    final rimRadius = radius * 0.58;
    canvas.drawCircle(
      center,
      rimRadius,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFFE8EDF5),
            Color(0xFF9AA6B8),
            Color(0xFF5B6675),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: rimRadius)),
    );
    // Rim inner shadow ring
    canvas.drawCircle(
      center,
      rimRadius * 0.82,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.07
        ..color = Colors.black.withValues(alpha: 0.25),
    );
    // Hub + spokes
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * 2 * pi;
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(angle) * rimRadius * 0.8,
          center.dy + sin(angle) * rimRadius * 0.8,
        ),
        Paint()
          ..strokeWidth = radius * 0.08
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF6B7686),
      );
    }
    canvas.drawCircle(
      center,
      radius * 0.14,
      Paint()..color = const Color(0xFF3E4652),
    );
  }

  @override
  bool shouldRepaint(covariant _CarPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.bobPhase != bobPhase;
  }
}
