import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/handbook_progress_repository.dart';
import '../../state/app_state.dart';

final handbookProgressRepositoryProvider = Provider<HandbookProgressRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return HandbookProgressRepository(prefs);
});

final handbookProgressProvider =
    StateNotifierProvider<HandbookProgressNotifier, Set<String>>((ref) {
  final repo = ref.watch(handbookProgressRepositoryProvider);
  return HandbookProgressNotifier(repo);
});

class HandbookProgressNotifier extends StateNotifier<Set<String>> {
  HandbookProgressNotifier(this._repo) : super(_repo.loadReadTopics());

  final HandbookProgressRepository _repo;

  /// Toggles the read status of a specific topic ID.
  void toggleTopicRead(String topicId) {
    if (state.contains(topicId)) {
      state = {...state}..remove(topicId);
    } else {
      state = {...state, topicId};
    }
    _repo.saveReadTopics(state);
  }

  /// Checks if a specific topic is marked as read.
  bool isTopicRead(String topicId) {
    return state.contains(topicId);
  }
}
