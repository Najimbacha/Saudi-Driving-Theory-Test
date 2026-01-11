import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<bool> confirmExitExam(BuildContext context) async {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  assert(() {
    debugPrint('Back: confirm exit exam');
    return true;
  }());
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 8),
      actionsPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber_rounded, color: scheme.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'exam.exitTitle'.tr(),
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
      content: Text(
        'exam.exitMessage'.tr(),
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('common.cancel'.tr()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                child: Text('exam.exitConfirm'.tr()),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  assert(() {
    debugPrint('Back: confirm exit exam result=${result == true}');
    return true;
  }());
  return result ?? false;
}
