enum QuestionType { letter, number }

class Question {
  final QuestionType type;
  final String questionText;
  final String imageUrl;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.type,
    required this.questionText,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
  });
}
