import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.border,
    this.blur = 12.0,
    this.gradient,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? color;
  final BoxBorder? border;
  final double blur;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: border ??
            Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        color: color ?? Colors.white.withValues(alpha: 0.05),
        gradient: gradient,
      ),
      child: child,
    );

    final clippedContent = ClipRRect(
      borderRadius: borderRadius,
      child: content,
    );

    if (blur <= 0) {
      return RepaintBoundary(
        child: Container(
          width: width,
          height: height,
          margin: margin,
          child: clippedContent,
        ),
      );
    }

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          ),
        ),
      ),
    );
  }
}
