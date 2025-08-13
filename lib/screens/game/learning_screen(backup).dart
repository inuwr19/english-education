import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';

// Model soal angka
class Question {
  final String questionText;
  final int correctAnswer;

  Question(this.questionText, this.correctAnswer);
}

// Model soal huruf
class LetterQuestion {
  final String incompleteWord; // contoh: "C_T"
  final String correctLetter; // contoh: "A"
  final String hint; // contoh: "CAT"

  LetterQuestion(this.incompleteWord, this.correctLetter, this.hint);
}

// Daftar kata untuk generate soal huruf
List<String> words = [
  "APPLE",
  "BANANA",
  "ORANGE",
  "MANGO",
  "GRAPE",
  "LEMON",
  "DOG",
  "CAT",
  "RABBIT",
  "HORSE",
];

// Generate soal angka acak
List<Question> generateRandomQuestions() {
  final List<Question> pool = [
    Question("ONE", 1),
    Question("FIVE", 5),
    Question("SEVEN", 7),
    Question("TWENTY", 20),
    Question("NINETY", 90),
    Question("THREE HUNDRED", 300),
    Question("ONE HUNDRED", 100),
    Question("FIFTY", 50),
    Question("TWO", 2),
    Question("EIGHT", 8),
  ];

  pool.shuffle();
  return pool.take(5).toList(); // ambil 5 soal
}

// Generate soal huruf otomatis
List<LetterQuestion> generateLetterQuestions(List<String> wordList, int count) {
  final rand = Random();
  final List<LetterQuestion> questions = [];

  wordList.shuffle();
  for (var word in wordList.take(count)) {
    if (word.length < 3) continue; // skip kata terlalu pendek

    // pilih index random di tengah (hindari huruf pertama & terakhir)
    int idx = rand.nextInt(word.length - 2) + 1;
    String missingLetter = word[idx];
    String incompleteWord =
        "${word.substring(0, idx)}_${word.substring(idx + 1)}";

    questions.add(LetterQuestion(incompleteWord, missingLetter, word));
  }
  return questions;
}

class LearningScreen extends StatefulWidget {
  final int grade;

  const LearningScreen({super.key, required this.grade});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late List<Question> numberQuestions;
  late List<LetterQuestion> letterQuestionsSet;
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    numberQuestions = generateRandomQuestions();
    letterQuestionsSet = generateLetterQuestions(
      words,
      5,
    ); // generate 5 soal huruf
  }

  bool get isNumberQuestion => currentQuestionIndex < numberQuestions.length;

  void handleNumberAnswer(int selectedAnswer) {
    final currentQuestion = numberQuestions[currentQuestionIndex];
    if (selectedAnswer == currentQuestion.correctAnswer) {
      correctAnswerNext();
    } else {
      wrongAnswer();
    }
  }

  void handleLetterAnswer(String selectedLetter) {
    final letterIdx = currentQuestionIndex - numberQuestions.length;
    final currentQuestion = letterQuestionsSet[letterIdx];
    if (selectedLetter == currentQuestion.correctLetter) {
      correctAnswerNext();
    } else {
      wrongAnswer();
    }
  }

  void correctAnswerNext() {
    setState(() {
      score++;
      if (currentQuestionIndex <
          (numberQuestions.length + letterQuestionsSet.length - 1)) {
        currentQuestionIndex++;
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Selesai!"),
            content: Text("Skor kamu: $score dari 10 soal"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Kembali"),
              ),
            ],
          ),
        );
      }
    });
  }

  void wrongAnswer() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jawaban salah, coba lagi!')));
  }

  @override
  Widget build(BuildContext context) {
    Widget questionWidget;
    List<Widget> optionsWidget;

    if (isNumberQuestion) {
      final currentQ = numberQuestions[currentQuestionIndex];
      final answerOptions = generateAnswerOptions(currentQ.correctAnswer);

      questionWidget = GradientStrokeText(
        text: currentQ.questionText,
        maxFontSize: 64,
      );

      optionsWidget = answerOptions.map((value) {
        return CustomButton(
          text: value.toString(),
          width: 80,
          height: 64,
          onTap: () => handleNumberAnswer(value),
        );
      }).toList();
    } else {
      final letterIdx = currentQuestionIndex - numberQuestions.length;
      final currentQ = letterQuestionsSet[letterIdx];

      questionWidget = Column(
        children: [
          GradientStrokeText(text: currentQ.incompleteWord, maxFontSize: 64),
          const SizedBox(height: 8),
        ],
      );

      optionsWidget = generateLetterOptions(currentQ.correctLetter).map((
        letter,
      ) {
        return CustomButton(
          text: letter,
          width: 80,
          height: 64,
          onTap: () => handleLetterAnswer(letter),
        );
      }).toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'asset/images/learning_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Tombol kembali
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'asset/images/back_button.png',
                        height: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Soal
                  Expanded(child: Center(child: questionWidget)),

                  // Jawaban
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: optionsWidget,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> generateAnswerOptions(int correctAnswer) {
    final rand = Random();
    final Set<int> options = {correctAnswer};

    while (options.length < 5) {
      int delta = rand.nextInt(20) + 1;
      int option = correctAnswer + (rand.nextBool() ? delta : -delta);
      if (option >= 0) options.add(option);
    }

    return options.toList()..shuffle();
  }

  List<String> generateLetterOptions(String correctLetter) {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final rand = Random();
    final options = {correctLetter};

    while (options.length < 5) {
      options.add(letters[rand.nextInt(letters.length)]);
    }

    return options.toList()..shuffle();
  }
}
