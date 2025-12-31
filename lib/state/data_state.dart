import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_repository.dart';
import '../models/question.dart';
import '../models/sign.dart';

final dataRepositoryProvider = Provider<DataRepository>((ref) => DataRepository());

final questionsProvider = FutureProvider<List<Question>>((ref) {
  return ref.read(dataRepositoryProvider).loadQuestions();
});

final signsProvider = FutureProvider<List<AppSign>>((ref) {
  return ref.read(dataRepositoryProvider).loadSigns();
});
