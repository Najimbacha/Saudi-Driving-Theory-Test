import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HandbookProgressRepository {
  const HandbookProgressRepository(this._prefs);

  static const String _storageKey = 'handbook_read_topics';

  final SharedPreferences _prefs;

  /// Loads the set of read topic IDs from local storage.
  Set<String> loadReadTopics() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return {};
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  /// Saves the set of read topic IDs to local storage.
  void saveReadTopics(Set<String> readTopics) {
    _prefs.setString(_storageKey, jsonEncode(readTopics.toList()));
  }
}
