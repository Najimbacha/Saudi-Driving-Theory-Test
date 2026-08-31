import 'package:flutter/material.dart';

/// Fades and slides its child in with a per-item stagger delay.
class StaggerIn extends StatelessWidget {
  const StaggerIn({super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = 40 * order;
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 240 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      child: child,
      builder: (context, value, builtChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: builtChild,
          ),
        );
      },
    );
  }
}
