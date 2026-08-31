import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CurriculumProgressRepository {
  const CurriculumProgressRepository(this._prefs);

  static const String _storageKey = 'curriculum_progress_v1';

  final SharedPreferences _prefs;

  Map<String, dynamic> loadProgress() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  void saveProgress(Map<String, dynamic> progress) {
    _prefs.setString(_storageKey, jsonEncode(progress));
  }
}
