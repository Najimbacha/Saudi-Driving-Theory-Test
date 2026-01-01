import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exam_result_model.dart';
import '../../data/repositories/exam_history_repository.dart';
import '../../state/app_state.dart';

final examHistoryRepositoryProvider = Provider<ExamHistoryRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ExamHistoryRepository(prefs);
});

final examHistoryProvider = StateNotifierProvider<ExamHistoryNotifier, List<ExamResult>>((ref) {
  final repo = ref.watch(examHistoryRepositoryProvider);
  return ExamHistoryNotifier(repo);
});

class ExamHistoryNotifier extends StateNotifier<List<ExamResult>> {
  ExamHistoryNotifier(this._repo) : super(_repo.loadHistory());

  final ExamHistoryRepository _repo;

  void addResult(ExamResult result) {
    _repo.saveResult(result);
    state = _repo.loadHistory();
  }
}
