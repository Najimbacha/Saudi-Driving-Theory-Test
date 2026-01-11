import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/home_shell.dart';

Future<void> handleAppBack(
  BuildContext context, {
  bool allowExit = true,
  NavigatorState? nestedNavigator,
  bool fromPopScope = false,
}) async {
  void log(String message) {
    if (kDebugMode) {
      debugPrint('Back: $message');
    }
  }

  final currentNav = nestedNavigator ?? Navigator.of(context);
  log(
    'start ${context.widget.runtimeType} (fromPopScope=$fromPopScope)',
  );

  if (nestedNavigator != null) {
    if (await nestedNavigator.maybePop()) {
      log('popped nested navigator');
      return;
    }
  } else if (!fromPopScope) {
    if (await currentNav.maybePop()) {
      log('popped current navigator');
      return;
    }
  }

  if (!context.mounted) return;
  final rootNav = Navigator.of(context, rootNavigator: true);
  final sameNavigator = identical(rootNav, currentNav);
  final skipRootPop = fromPopScope && nestedNavigator != null;
  if (!skipRootPop && (!fromPopScope || !sameNavigator)) {
    if (rootNav.canPop()) {
      if (await rootNav.maybePop()) {
        log('popped root navigator');
        return;
      }
    }
  }

  if (!context.mounted) return;
  final shell = TabShellScope.maybeOf(context);
  if (shell != null && shell.value != 0) {
    log('switch tab to 0');
    shell.value = 0;
    return;
  }

  if (allowExit) {
    log('exit app');
    SystemNavigator.pop();
  }
}
