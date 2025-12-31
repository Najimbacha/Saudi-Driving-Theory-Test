class Question {
  const Question({
    required this.id,
    required this.categoryKey,
    required this.difficultyKey,
    required this.questionKey,
    required this.optionsKeys,
    required this.correctIndex,
    required this.explanationKey,
    required this.signId,
  });

  final String id;
  final String categoryKey;
  final String difficultyKey;
  final String questionKey;
  final List<String> optionsKeys;
  final int correctIndex;
  final String? explanationKey;
  final String? signId;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      categoryKey: json['categoryKey'] as String,
      difficultyKey: json['difficultyKey'] as String,
      questionKey: json['questionKey'] as String,
      optionsKeys: List<String>.from(json['optionsKeys'] ?? const []),
      correctIndex: (json['correctIndex'] ?? json['correctAnswer'] ?? 0) as int,
      explanationKey: json['explanationKey'] as String?,
      signId: json['signId'] as String?,
    );
  }
}
