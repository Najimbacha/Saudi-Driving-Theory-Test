import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';
import '../models/sign.dart';

class DataRepository {
  Future<List<Question>> loadQuestions() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final jsonData = jsonDecode(raw) as Map<String, dynamic>;
    final list =
        List<Map<String, dynamic>>.from(jsonData['questions'] ?? const []);
    return list.map(Question.fromJson).toList();
  }

  Future<List<AppSign>> loadSigns() async {
    final raw = await rootBundle.loadString('assets/data/ksa_signs.json');
    final jsonData = jsonDecode(raw) as List<dynamic>;
    final list = List<Map<String, dynamic>>.from(jsonData);
    return list.map(AppSign.fromJson).toList();
  }
}
