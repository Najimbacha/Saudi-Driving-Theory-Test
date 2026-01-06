import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_repository.dart';
import '../models/question.dart';
import '../models/sign.dart';

final dataRepositoryProvider =
    Provider<DataRepository>((ref) => DataRepository());

/// ROOT FIX: Removed locale watching from questionsProvider
/// Questions don't need to reload when language changes because:
/// 1. JSON contains all languages (multi-language data)
/// 2. Widgets read context.locale.languageCode dynamically in _questionText/_options helpers
/// 3. EasyLocalization's InheritedWidget causes rebuilds automatically when locale changes
final questionsProvider = FutureProvider<List<Question>>((ref) {
  return ref.read(dataRepositoryProvider).loadQuestions();
});

/// ROOT FIX: Removed locale watching from signsProvider
/// Signs are language-agnostic (SVG images)
/// Any localized labels are handled by widgets reading context.locale directly
final signsProvider = FutureProvider<List<AppSign>>((ref) {
  return ref.read(dataRepositoryProvider).loadSigns();
});
