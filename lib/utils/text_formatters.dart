import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String formatProgress(BuildContext context, int current, int total) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = NumberFormat.decimalPattern(locale);
  final currentText = formatter.format(current);
  final totalText = formatter.format(total);
  return '$currentText / $totalText';
}

String formatCorrectAnswers(BuildContext context, int correct, int total) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = NumberFormat.decimalPattern(locale);
  final correctText = formatter.format(correct);
  final totalText = formatter.format(total);
  return 'exam.scoreSummary'.tr(namedArgs: {
    'correct': correctText,
    'total': totalText,
  });
}

String formatQuestionOf(BuildContext context, int current, int total) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = NumberFormat.decimalPattern(locale);
  final currentText = formatter.format(current);
  final totalText = formatter.format(total);
  return 'common.questionOf'.tr(namedArgs: {
    'current': currentText,
    'total': totalText,
  });
}
