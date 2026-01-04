import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../models/question.dart';
import '../../state/data_state.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return const CategoryRepository();
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.loadCategories();
});

/// Optimized provider to count questions per category
/// Re-computes only when questions data changes
final categoryQuestionCountsProvider = Provider<Map<String, int>>((ref) {
  final questionsAsync = ref.watch(questionsProvider);
  final questions = questionsAsync.valueOrNull ?? [];
  final counts = <String, int>{};
  
  for (final question in questions) {
    counts.update(
      question.categoryId,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return counts;
});
