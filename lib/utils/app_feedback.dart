import 'package:flutter/material.dart';

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

  static void _noop() {
    // Feedback disabled by design.
  }
}
