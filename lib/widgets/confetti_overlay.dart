import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });

  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  int shape; // 0: rectangle, 1: circle, 2: diamond
}

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.child,
    this.autoStart = true,
  });

  final Widget child;
  final bool autoStart;

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();
  double _width = 400;

  static const List<Color> _confettiColors = [
    Color(0xFF10B981), // Emerald
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber / Gold
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addListener(_updateParticles);

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        play();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void play() {
    _particles.clear();
    for (int i = 0; i < 70; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble() * _width,
          y: -20 - _random.nextDouble() * 100,
          vx: (_random.nextDouble() - 0.5) * 6,
          vy: 3 + _random.nextDouble() * 6,
          size: 6 + _random.nextDouble() * 6,
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
          shape: _random.nextInt(3),
        ),
      );
    }
    _controller.forward(from: 0);
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.12; // gravity
      p.rotation += p.rotationSpeed;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth > 0 ? constraints.maxWidth : 400;
        return Stack(
          children: [
            widget.child,
            if (_controller.isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      opacity: 1.0 - _controller.value * 0.8,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.opacity});

  final List<ConfettiParticle> particles;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      paint.color = p.color.withValues(alpha: (opacity * 0.9).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(p.x % size.width, p.y);
      canvas.rotate(p.rotation);

      if (p.shape == 0) {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 1.6,
          ),
          paint,
        );
      } else if (p.shape == 1) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Diamond / Star
        final path = Path()
          ..moveTo(0, -p.size)
          ..lineTo(p.size * 0.7, 0)
          ..lineTo(0, p.size)
          ..lineTo(-p.size * 0.7, 0)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
