import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFeedback {
  static void tap(BuildContext context) {
    _noop();
  }

  static void confirm(BuildContext context) {
    _noop();
  }

  static void selection(BuildContext context) {
    _noop();
  }

  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void _noop() {
    // Feedback disabled by design.
  }
}
