import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_state.dart';
import '../../data/models/handbook_model.dart';

/// Reads and parses the entire theory handbook JSON file into memory for instant access.
final handbookProvider = FutureProvider<HandbookData>((ref) async {
  try {
    // Determine the current locale from the ref or app state
    // Note: handbookProvider does not directly watch the locale provider to avoid rebuild loop if logic is nested,
    // but we can pass the locale code if we use a family or handle it inside.
    // However, EasyLocalization's values are usually available via context, which isn't here.
    // For now, we use a simple approach: check the current app state or use a default.
    // Let's make it a family or watch the locale.
    
    // We'll rely on the app state or a specific locale provider if available.
    // Looking at main.dart, it uses Locale('en'), ('ar'), etc.
    
    // For now, let's load the file based on a simple logic or wait for a specific 'currentLocaleProvider'.
    // If we can't easily get it, we'll implement a fallback pattern.
    
    // Actually, let's just make it simpler: the provider will look for 'saudi_driving_theory_data_{lang}.json'
    // We can use ref.watch(appStateProvider).locale if it exists.
    
    final lang = ref.watch(appSettingsProvider).languageCode;
    final assetPath = 'assets/data/saudi_driving_theory_data_$lang.json';
    
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(assetPath);
    } catch (_) {
      // Fallback to English if the localized file doesn't exist
      jsonString = await rootBundle.loadString('assets/data/saudi_driving_theory_data_complete.json');
    }
    
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return HandbookData.fromJson(jsonMap);
  } catch (e, _) {
    debugPrint('Failed to load handbook data: $e');
    rethrow;
  }
});

/// A convenience provider that yields only the `HandbookInfo` payload.
final handbookInfoProvider = FutureProvider<HandbookInfo>((ref) async {
  final parent = await ref.watch(handbookProvider.future);
  return parent.appData;
});

/// A provider that extracts all subtopics from the handbook into a searchable flat list.
/// Useful for building a quick-search or flashcard deck index.
final flatSubtopicsProvider = FutureProvider<List<HandbookSubtopic>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  final List<HandbookSubtopic> results = [];
  
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      results.addAll(topic.subtopics);
    }
  }
  return results;
});

// ---------------------------------------------------------------------------
// Violation Points (topic 1.6)
// ---------------------------------------------------------------------------

/// Extracts the 21-item violation points table from the JSON.
final violationPointsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.6') {
        final table = topic.extraData['points_table'];
        if (table is List) {
          return table.cast<Map<String, dynamic>>();
        }
      }
    }
  }
  return [];
});

/// Extracts the license withdrawal schedule from the JSON.
final licenseWithdrawalProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.6') {
        final schedule = topic.extraData['license_withdrawal_schedule'];
        if (schedule is List) {
          return schedule.cast<Map<String, dynamic>>();
        }
      }
    }
  }
  return [];
});

/// Maximum points before license withdrawal.
final maxViolationPointsProvider = FutureProvider<int>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.6') {
        return (topic.extraData['max_points_before_license_withdrawal']
                as int?) ??
            24;
      }
    }
  }
  return 24;
});

// ---------------------------------------------------------------------------
// Traffic Fines (topic 1.5)
// ---------------------------------------------------------------------------

/// Extracts violation fine tables 1–7 from the JSON.
final trafficFineTablesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.5') {
        final tables = topic.extraData['violation_tables'];
        if (tables is List) {
          return tables.cast<Map<String, dynamic>>();
        }
      }
    }
  }
  return [];
});

/// Extracts drifting penalties from the JSON.
final driftingPenaltiesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.5') {
        final penalties = topic.extraData['drifting_penalties'];
        if (penalties is List) {
          return penalties.cast<Map<String, dynamic>>();
        }
      }
    }
  }
  return [];
});

// ---------------------------------------------------------------------------
// Sign Categories (topic 1.9)
// ---------------------------------------------------------------------------

/// Extracts sign category info (shape, color, purpose) from the JSON.
final signCategoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    for (final topic in unit.topics) {
      if (topic.topicId == '1.9') {
        final categories = topic.extraData['categories'];
        if (categories is List) {
          return categories.cast<Map<String, dynamic>>();
        }
      }
    }
  }
  return [];
});

// ---------------------------------------------------------------------------
// Priority Rules (topic 4.4)
// ---------------------------------------------------------------------------

/// Extracts the priority hierarchy and rules from Unit 4.4.
final priorityRulesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final info = await ref.watch(handbookInfoProvider.future);
  for (final unit in info.units) {
    if (unit.unitId == 4) {
      for (final topic in unit.topics) {
        if (topic.topicId == '4.4') {
          return topic.extraData;
        }
      }
    }
  }
  return {};
});

// ---------------------------------------------------------------------------
// Key Numbers Summary
// ---------------------------------------------------------------------------

/// Extracts the global key numbers summary from the JSON.
final keyNumbersProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final parent = await ref.watch(handbookProvider.future);
  // The key_numbers_summary is at the root level of the data object
  return parent.extraData['key_numbers_summary'] as Map<String, dynamic>? ?? {};
});
