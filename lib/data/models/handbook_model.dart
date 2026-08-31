class HandbookData {
  final HandbookInfo appData;
  final Map<String, dynamic> extraData;

  HandbookData({required this.appData, this.extraData = const {}});

  factory HandbookData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('app_data')) {
      throw const FormatException('Missing app_data key in handbook JSON');
    }

    final appDataMap = json['app_data'] as Map<String, dynamic>;
    final Map<String, dynamic> extra = {};
    
    // 1. Grab extra data at the root level
    json.forEach((key, value) {
      if (key != 'app_data') {
        extra[key] = value;
      }
    });
    
    // 2. Grab extra data that was accidentally nested inside app_data
    appDataMap.forEach((key, value) {
      if (!['version', 'language', 'title', 'issued_by', 'introduction', 'units'].contains(key)) {
        extra[key] = value;
      }
    });

    return HandbookData(
      appData: HandbookInfo.fromJson(appDataMap),
      extraData: extra,
    );
  }
}

class HandbookInfo {
  final String version;
  final String language;
  final String title;
  final String issuedBy;
  final String introduction;
  final List<HandbookUnit> units;

  HandbookInfo({
    required this.version,
    required this.language,
    required this.title,
    required this.issuedBy,
    required this.introduction,
    required this.units,
  });

  factory HandbookInfo.fromJson(Map<String, dynamic> json) {
    return HandbookInfo(
      version: json['version'] ?? '',
      language: json['language'] ?? 'en',
      title: json['title'] ?? '',
      issuedBy: json['issued_by'] ?? '',
      introduction: json['introduction'] ?? '',
      units: (json['units'] as List?)
              ?.map((e) => HandbookUnit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HandbookUnit {
  final int unitId;
  final String title;
  final List<HandbookTopic> topics;

  HandbookUnit({
    required this.unitId,
    required this.title,
    required this.topics,
  });

  factory HandbookUnit.fromJson(Map<String, dynamic> json) {
    return HandbookUnit(
      unitId: json['unit_id'] as int? ?? 0,
      title: json['title'] ?? '',
      topics: (json['topics'] as List?)
              ?.map((e) => HandbookTopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HandbookTopic {
  final String topicId;
  final String title;
  final List<HandbookSubtopic> subtopics;

  /// In the JSON, some topics put data straight into the topic object instead of a subtopics array.
  /// (Like topic_id: "1.4" Traffic Department)
  /// We capture all these stray key/values into [extraData] for dynamic rendering.
  final Map<String, dynamic> extraData;

  HandbookTopic({
    required this.topicId,
    required this.title,
    required this.subtopics,
    this.extraData = const {},
  });

  factory HandbookTopic.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> extra = {};
    json.forEach((key, value) {
      if (key != 'topic_id' && key != 'title' && key != 'subtopics') {
        extra[key] = value;
      }
    });

    return HandbookTopic(
      topicId: json['topic_id'] ?? '',
      title: json['title'] ?? '',
      extraData: extra,
      subtopics: (json['subtopics'] as List?)
              ?.map((e) => HandbookSubtopic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HandbookSubtopic {
  final String subtopicId;
  final String title;

  /// Because subtopic structures vary wildly across this 2000-line JSON
  /// (arrays of strings vs objects with named fields like 'fine_range_sar'),
  /// we retain the raw map to render widgets dynamically based on keys.
  final Map<String, dynamic> contentData;

  HandbookSubtopic({
    required this.subtopicId,
    required this.title,
    required this.contentData,
  });

  factory HandbookSubtopic.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> content = {};
    json.forEach((key, value) {
      if (key != 'subtopic_id' && key != 'title') {
        content[key] = value;
      }
    });

    return HandbookSubtopic(
      subtopicId: json['subtopic_id'] ?? '',
      title: json['title'] ?? '',
      contentData: content,
    );
  }
}
