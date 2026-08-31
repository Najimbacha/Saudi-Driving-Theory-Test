import 'package:flutter/material.dart';

import '../core/theme/modern_theme.dart';

/// Shows a consistent, beautiful toast across the app.
///
/// Styled globally via the theme's SnackBarThemeData, with optional
/// success/error accent icons.
void showAppToast(
  BuildContext context,
  String message, {
  bool error = false,
  bool success = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  final color = error
      ? ModernTheme.coral
      : success
          ? ModernTheme.emerald
          : null;

  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (color != null) ...[
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: color ?? const Color(0xFF1E293B),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      duration: const Duration(milliseconds: 2200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}
