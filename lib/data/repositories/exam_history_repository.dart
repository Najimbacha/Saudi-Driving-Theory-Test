import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam_result_model.dart';

class ExamHistoryRepository {
  const ExamHistoryRepository(this._prefs);

  static const String _storageKey = 'exam_history';

  final SharedPreferences _prefs;

  List<ExamResult> loadHistory() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return const [];
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((e) => ExamResult.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void saveResult(ExamResult result) {
    final list = loadHistory();
    final updated = [result, ...list];
    _prefs.setString(_storageKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }
}
