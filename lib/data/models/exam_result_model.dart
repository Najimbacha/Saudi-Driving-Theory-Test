class QuestionAnswer {
  const QuestionAnswer({
    required this.questionId,
    required this.userAnswerIndex,
    required this.correctAnswerIndex,
  });

  final String questionId;
  final int userAnswerIndex;
  final int correctAnswerIndex;

  bool get isCorrect => userAnswerIndex == correctAnswerIndex;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'userAnswerIndex': userAnswerIndex,
        'correctAnswerIndex': correctAnswerIndex,
      };

  static QuestionAnswer fromJson(Map<String, dynamic> json) => QuestionAnswer(
        questionId: json['questionId'] as String,
        userAnswerIndex: json['userAnswerIndex'] as int,
        correctAnswerIndex: json['correctAnswerIndex'] as int,
      );
}

class ExamResult {
  const ExamResult({
    required this.id,
    required this.dateTime,
    required this.examType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.scorePercentage,
    required this.passed,
    required this.timeTakenSeconds,
    required this.categoryScores,
    required this.questionAnswers,
  });

  final String id;
  final DateTime dateTime;
  final String examType;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final double scorePercentage;
  final bool passed;
  final int timeTakenSeconds;
  final Map<String, int> categoryScores;
  final List<QuestionAnswer> questionAnswers;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'examType': examType,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'skippedAnswers': skippedAnswers,
        'scorePercentage': scorePercentage,
        'passed': passed,
        'timeTakenSeconds': timeTakenSeconds,
        'categoryScores': categoryScores,
        'questionAnswers': questionAnswers.map((e) => e.toJson()).toList(),
      };

  static ExamResult fromJson(Map<String, dynamic> json) => ExamResult(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        examType: json['examType'] as String,
        totalQuestions: json['totalQuestions'] as int,
        correctAnswers: json['correctAnswers'] as int,
        wrongAnswers: json['wrongAnswers'] as int,
        skippedAnswers: json['skippedAnswers'] as int,
        scorePercentage: (json['scorePercentage'] as num).toDouble(),
        passed: json['passed'] as bool,
        timeTakenSeconds: json['timeTakenSeconds'] as int,
        categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
        questionAnswers: (json['questionAnswers'] as List<dynamic>)
            .map((e) => QuestionAnswer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
