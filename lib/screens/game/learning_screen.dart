import 'dart:math';
import 'package:english_education/shared/sound_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';

/// =======================
/// MODELS
/// =======================
class Question {
  final String questionText;
  final int correctAnswer;
  Question(this.questionText, this.correctAnswer);
}

class LetterQuestion {
  final String incompleteWord;
  final String correctLetter;
  final String hint;
  LetterQuestion(this.incompleteWord, this.correctLetter, this.hint);
}

class DailyActivityQuestion {
  final String imagePath;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  DailyActivityQuestion(
    this.imagePath,
    this.questionText,
    this.options,
    this.correctAnswer,
  );
}

class PrepositionQuestion {
  final String imagePath;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  PrepositionQuestion(
    this.imagePath,
    this.questionText,
    this.options,
    this.correctAnswer,
  );
}

class MCQQuestion {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  MCQQuestion(this.questionText, this.options, this.correctAnswer);
}

class ImageMCQQuestion {
  final String imagePath;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  ImageMCQQuestion(
    this.imagePath,
    this.questionText,
    this.options,
    this.correctAnswer,
  );
}

/// =======================
/// DATA SOURCES
/// =======================

// Grade 1 – words
final List<String> words = [
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

// Grade 3 – Daily
final List<DailyActivityQuestion> dailyActivityPool = [
  DailyActivityQuestion('asset/images/daily1.png', "What is she doing?", [
    "Rina is always do home workout",
    "Rina do Home Workout",
    "Rina standing everyday",
    "Rina is playing video games",
  ], "Rina do Home Workout"),
  DailyActivityQuestion(
    'asset/images/daily2.png',
    "What are they do?",
    [
      "They walked together",
      "They are going back home",
      "They are go to school together",
      "They went to school",
    ],
    "They are go to school together",
  ),
  DailyActivityQuestion(
    'asset/images/daily3.png',
    "What is Bima doing?",
    [
      "A. Bima is not like his food ",
      "B. Bima is watching a movie ",
      "C. Bima is really like he lunch meal ",
      "D. Bima is really like his lunch meal",
    ],
    "D. Bima is really like his lunch meal",
  ),
  DailyActivityQuestion('asset/images/daily4.png', "What is Naura doing?", [
    "A. Naura is take a bath",
    "B. Naura are sleep in the bedroom",
    "C. Naura take a shower",
    "D, Naura Playing with her bumble",
  ], "A. Naura is take a bath"),
  DailyActivityQuestion(
    'asset/images/daily5.png',
    "What Are They Do?",
    [
      "A. My Family are always dinner together",
      "B. My Family Eat our Own dinner",
      "C. Me And My parents are dinnerr together ",
      "D. We are ate dinner Together",
    ],
    "A. My Family are always dinner together",
  ),
];

// Grade 3 – Preposition
final List<PrepositionQuestion> prepositionPool = [
  PrepositionQuestion('asset/images/prep1.png', "Where is the cat?", [
    "On the table",
    "Under the table",
    "Beside the table",
    "In the box",
  ], "In the box"),
  PrepositionQuestion('asset/images/prep2.png', "Where is the ball?", [
    "In the box",
    "On the box",
    "Under the box",
    "Next to the box",
  ], "In the box"),
  PrepositionQuestion('asset/images/prep3.png', "Where is the dog?", [
    "Behind the house",
    "In the house",
    "On the roof",
    "Under the house",
  ], "Behind the house"),
  PrepositionQuestion('asset/images/prep4.png', "Where is the book?", [
    "On the shelf",
    "Under the chair",
    "Beside the bed",
    "In the bag",
  ], "In the bag"),
  PrepositionQuestion('asset/images/prep5.png', "Where is the apple?", [
    "On the plate",
    "Under the plate",
    "In the plate",
    "Beside the plate",
  ], "On the plate"),
];

// Grade 2 – Adjective MCQ (tanpa gambar)
final List<MCQQuestion> grade2AdjectivePool = [
  MCQQuestion("The red apple is . . . than the green apple", [
    "sweeter",
    "tallest",
    "fastest",
  ], "sweeter"),
  MCQQuestion("A feather is . . . than a stone", [
    "lighter",
    "heavier",
    "larger",
  ], "lighter"),
  MCQQuestion("This puzzle is the . . . of all", [
    "easiest",
    "more easy",
    "easy",
  ], "easiest"),
  MCQQuestion("My bag is . . . than your bag", [
    "bigger",
    "biggest",
    "big",
  ], "bigger"),
  MCQQuestion("The turtle is the . . . animal in the race", [
    "slowest",
    "slower",
    "slow",
  ], "slowest"),
];

// Grade 2 – Adjective MCQ (bergambar)
final List<ImageMCQQuestion> grade2AdjectiveImagePool = [
  ImageMCQQuestion(
    'asset/images/learning_grade2_adjective.jpg',
    "Kemala's father is . . . than Kemala",
    ["taller", "shorter", "smaller"],
    "taller",
  ),
  ImageMCQQuestion(
    'asset/images/learning_grade2_adjective.jpg',
    "There are . . . people in Kemala's family",
    ["three", "four", "five"],
    "four",
  ),
  ImageMCQQuestion(
    'asset/images/learning_grade2_adjective.jpg',
    "Kemala's brother is . . . than Kemala",
    ["taller", "shorter", "smaller"],
    "shorter",
  ),
  ImageMCQQuestion(
    'asset/images/learning_grade2_adjective.jpg',
    "Kemala's mother is . . . than Kemala's father",
    ["taller", "shorter", "shortest"],
    "shorter",
  ),
  ImageMCQQuestion(
    'asset/images/learning_grade2_adjective.jpg',
    "Kemala is . . . than Kemala's sister",
    ["taller", "shorter", "smaller"],
    "smaller",
  ),
];

final List<dynamic> grade2Pool = [
  ...grade2AdjectivePool,
  ...grade2AdjectiveImagePool,
]..shuffle();

/// =======================
/// UTILS – GENERATORS
/// =======================
List<Question> generateRandomQuestions() {
  final pool = <Question>[
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
  ]..shuffle();
  return pool.take(5).toList();
}

List<LetterQuestion> generateLetterQuestions(List<String> wordList, int count) {
  final rand = Random();
  final List<LetterQuestion> qs = [];
  final shuffled = [...wordList]..shuffle();

  int taken = 0, i = 0;
  while (taken < count && i < shuffled.length) {
    final w = shuffled[i++];
    if (w.length < 3) continue;
    final idx = rand.nextInt(w.length - 2) + 1; // avoid first & last
    final missing = w[idx];
    final incomplete = "${w.substring(0, idx)}_${w.substring(idx + 1)}";
    qs.add(LetterQuestion(incomplete, missing, w));
    taken++;
  }

  while (qs.length < count) {
    final w = wordList[rand.nextInt(wordList.length)];
    if (w.length < 3) continue;
    final idx = rand.nextInt(w.length - 2) + 1;
    final missing = w[idx];
    final incomplete = "${w.substring(0, idx)}_${w.substring(idx + 1)}";
    qs.add(LetterQuestion(incomplete, missing, w));
  }
  return qs;
}

/// =======================
/// MAIN WIDGET
/// =======================
class LearningScreen extends StatefulWidget {
  final int grade;
  const LearningScreen({super.key, required this.grade});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class OptionCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double maxFontSize;

  const OptionCard({
    super.key,
    required this.text,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.maxFontSize = 20, // Grade 2 default; Grade 3 bisa 18–20
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SoundService.instance.tap();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.orange.withOpacity(0.15),
        highlightColor: Colors.orange.withOpacity(0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // gradient lembut, biar kontras dg stroke text
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF5E7), Color(0xFFFFE3C2)],
            ),
            border: Border.all(color: Colors.orange.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: GradientStrokeText(
              text: text,
              maxFontSize: maxFontSize,
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningScreenState extends State<LearningScreen> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    if (widget.grade == 1) {
      questions = [
        ...generateRandomQuestions(),
        ...generateLetterQuestions(words, 5),
      ];
    } else if (widget.grade == 2) {
      questions = [...grade2Pool];
    } else if (widget.grade == 3) {
      questions = [...dailyActivityPool, ...prepositionPool]..shuffle();
    } else {
      questions = [
        ...generateRandomQuestions(),
        ...generateLetterQuestions(words, 5),
      ];
    }
  }

  /// =======================
  /// GAME FLOW
  /// =======================
  void checkAnswer(dynamic question, dynamic selected) {
    bool correct = false;
    if (question is Question) {
      correct = selected == question.correctAnswer;
    } else if (question is LetterQuestion) {
      correct = selected == question.correctLetter;
    } else if (question is DailyActivityQuestion ||
        question is PrepositionQuestion ||
        question is MCQQuestion ||
        question is ImageMCQQuestion) {
      final answer = (question as dynamic).correctAnswer as String;
      correct = selected == answer;
    }
    if (correct) {
      SoundService.instance.correct();
      nextQuestion(true);
    } else {
      SoundService.instance.wrong();
      wrongAnswer();
    }
  }

  void nextQuestion(bool correct) {
    setState(() {
      if (correct) score++;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Selesai!"),
            content: Text("Skor kamu: $score dari ${questions.length} soal"),
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

  /// =======================
  /// HELPERS UI — Buttons
  /// =======================
  Widget _btnG1(String text, VoidCallback onTap) =>
      CustomButtonExtensions.small(text: text, onTap: onTap);

  Widget _btnG23(
    String text,
    VoidCallback onTap,
    double width, {
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    double maxFontSize = 20, // G2 default
  }) {
    return SizedBox(
      width: width,
      child: OptionCard(
        text: text,
        onTap: onTap,
        padding: padding,
        maxFontSize: maxFontSize,
      ),
    );
  }

  /// grid 2 kolom serbaguna (non-scroll)
  Widget _twoCols({
    required List<String> options,
    required void Function(String) onTap,
    required bool forGrade3,
  }) {
    const cols = 2;
    const gap = 12.0;

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final colW = (maxW - ((cols - 1) * gap)) / cols;

        // Lebar & ukuran teks
        final targetW = forGrade3
            ? colW.clamp(140.0, 170.0)
            : colW.clamp(140.0, 200.0);
        final fontSize = forGrade3 ? 18.0 : 20.0;
        final pad = forGrade3
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: options.map((opt) {
            return _btnG23(
              opt,
              () => onTap(opt),
              targetW,
              padding: pad,
              maxFontSize: fontSize,
            );
          }).toList(),
        );
      },
    );
  }

  /// kotak pertanyaan compact (dipakai G2/G3)
  Widget _questionBox(String text, {double fontSize = 18, int maxLines = 3}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.indigo,
        ),
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// gambar terbatasi tinggi
  Widget _boundedImage(String path, double maxH) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, _, __) => Container(
            height: maxH,
            color: Colors.grey[300],
            child: const Center(child: Text('Image missing')),
          ),
        ),
      ),
    );
  }

  /// =======================
  /// BUILD
  /// =======================
  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('Tidak ada soal')));
    }

    final q = questions[currentQuestionIndex];
    final mq = MediaQuery.of(context);
    final bottomSafe = max(mq.viewPadding.bottom, 16.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('asset/images/learning_bg.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.lightBlue.withOpacity(0.2),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'asset/images/back_button.png',
                        height:
                            44, // sedikit lebih kecil agar aman di device kecil
                        errorBuilder: (c, e, s) => const CircleAvatar(
                          backgroundColor: Colors.white70,
                          child: Icon(Icons.arrow_back, color: Colors.blue),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Score: $score / ${questions.length}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSafe),
                  child: LayoutBuilder(
                    builder: (context, cons) {
                      final h = cons.maxHeight;
                      final compact =
                          h < 700; // fallback ke scroll kalau sempit

                      Widget content;

                      if (widget.grade == 1) {
                        // -------- Grade 1 --------
                        final h = cons.maxHeight;
                        final compact =
                            h < 620; // ambang “layar pendek” (boleh kamu ubah)

                        // TOP AREA
                        Widget topArea;
                        if (q is Question) {
                          topArea = Center(
                            child: GradientStrokeText(
                              text: q.questionText,
                              maxFontSize: 56,
                            ),
                          );
                        } else if (q is LetterQuestion) {
                          topArea = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GradientStrokeText(
                                text: q.incompleteWord,
                                maxFontSize: 56,
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        } else {
                          topArea = const SizedBox.shrink();
                        }

                        // BUTTONS
                        List<Widget> buttons = [];
                        if (q is Question) {
                          final nums = generateAnswerOptions(q.correctAnswer);
                          buttons = nums
                              .take(4)
                              .map(
                                (n) => _btnG1(
                                  n.toString(),
                                  () => checkAnswer(q, n),
                                ),
                              )
                              .toList();
                        } else if (q is LetterQuestion) {
                          final letters = generateLetterOptions(
                            q.correctLetter,
                          );
                          buttons = letters
                              .take(4)
                              .map((l) => _btnG1(l, () => checkAnswer(q, l)))
                              .toList();
                        }

                        final content = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            topArea,
                            const SizedBox(height: 12),
                            // Grid TIDAK dibungkus Expanded lagi → tinggi fleksibel
                            _gridOptionsG1(buttons),
                            const SizedBox(height: 8),
                          ],
                        );

                        // Kalau sempit → scroll; kalau lega → tidak scroll
                        return compact
                            ? SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: content,
                              )
                            : content;
                      } else if (widget.grade == 2) {
                        // ---------- GRADE 2 ----------
                        final imgMaxH = compact ? h * 0.18 : h * 0.22;
                        final optH = compact ? h * 0.48 : h * 0.50;

                        Widget topArea;
                        if (q is ImageMCQQuestion) {
                          topArea = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _boundedImage(q.imagePath, imgMaxH),
                              const SizedBox(height: 8),
                              _questionBox(
                                q.questionText,
                                fontSize: compact ? 16 : 18,
                                maxLines: 2,
                              ),
                            ],
                          );
                        } else if (q is MCQQuestion) {
                          topArea = _questionBox(
                            q.questionText,
                            fontSize: compact ? 16 : 18,
                            maxLines: 2,
                          );
                        } else {
                          topArea = const SizedBox.shrink();
                        }

                        final opts = (q is ImageMCQQuestion)
                            ? q.options
                            : (q is MCQQuestion)
                            ? q.options
                            : <String>[];

                        final options = SizedBox(
                          height: optH,
                          child: _twoCols(
                            options: opts,
                            onTap: (sel) => checkAnswer(q, sel),
                            forGrade3: false,
                          ),
                        );

                        content = Column(
                          children: [
                            const SizedBox(height: 8),
                            topArea,
                            const SizedBox(height: 8),
                            options,
                            if (!compact) const Spacer(),
                          ],
                        );
                      } else {
                        // ---------- GRADE 3 ----------
                        final imgMaxH = compact ? h * 0.22 : h * 0.28;
                        final qBoxH = compact ? h * 0.16 : h * 0.18;
                        final optH = compact ? h * 0.46 : h * 0.40;

                        String qText = "";
                        Widget img = const SizedBox.shrink();
                        if (q is DailyActivityQuestion) {
                          img = _boundedImage(q.imagePath, imgMaxH);
                          qText = q.questionText;
                        } else if (q is PrepositionQuestion) {
                          img = _boundedImage(q.imagePath, imgMaxH);
                          qText = q.questionText;
                        } else if (q is ImageMCQQuestion) {
                          img = _boundedImage(q.imagePath, imgMaxH);
                          qText = q.questionText;
                        } else if (q is MCQQuestion) {
                          qText = q.questionText;
                        }

                        final questionBox = SizedBox(
                          height: qBoxH,
                          child: Center(
                            child: _questionBox(
                              qText,
                              fontSize: compact ? 16 : 18,
                              maxLines: 3,
                            ),
                          ),
                        );

                        final opts = (q is DailyActivityQuestion)
                            ? q.options
                            : (q is PrepositionQuestion)
                            ? q.options
                            : (q is ImageMCQQuestion)
                            ? q.options
                            : (q is MCQQuestion)
                            ? q.options
                            : <String>[];

                        final options = SizedBox(
                          height: optH,
                          child: _twoColsGridG3(
                            options: opts,
                            onTap: (sel) => checkAnswer(q, sel),
                            compact: compact,
                          ),
                        );

                        content = Column(
                          children: [
                            const SizedBox(height: 8),
                            img,
                            const SizedBox(height: 8),
                            questionBox,
                            const SizedBox(height: 12),
                            options,
                            if (!compact) const Spacer(),
                          ],
                        );
                      }

                      // ❗️Fallback ke scroll bila very-compact
                      if (compact) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: content,
                        );
                      }
                      return content;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _twoColsGridG3({
    required List<String> options,
    required void Function(String) onTap,
    bool compact = false,
  }) {
    const cols = 2;
    const gap = 12.0;
    final items = (options.length >= 4)
        ? options.take(4).toList()
        : [...options, ...List.filled(4 - options.length, '')];

    return LayoutBuilder(
      builder: (context, c) {
        final cellH = compact ? 52.0 : 60.0; // sedikit lebih pendek saat sempit
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: cellH,
          ),
          itemCount: 4,
          itemBuilder: (_, i) {
            final text = items[i];
            if (text.isEmpty) return const SizedBox.shrink();
            return OptionCard(
              text: text,
              onTap: () => onTap(text),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              maxFontSize: compact ? 17 : 18,
            );
          },
        );
      },
    );
  }

  Widget _gridOptionsG1(List<Widget> buttons) {
    const cols = 2;
    const gap = 12.0;

    return LayoutBuilder(
      builder: (context, c) {
        // tinggi setiap cell tombol; aman di semua device
        const cellH = 60.0;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            bottom: 12,
          ), // ruang ekstra agar tak “ngepas”
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            mainAxisExtent: cellH, // <- bukan aspectRatio lagi
          ),
          itemCount: buttons.length.clamp(0, 4), // 2x2
          itemBuilder: (_, i) => buttons[i],
        );
      },
    );
  }

  /// =======================
  /// ANSWER OPTION GENERATORS
  /// =======================
  List<int> generateAnswerOptions(int correctAnswer) {
    final rand = Random();
    final options = <int>{correctAnswer};
    final optionCount = widget.grade == 1 ? 4 : 5;
    while (options.length < optionCount) {
      final delta = rand.nextInt(20) + 1;
      final v = correctAnswer + (rand.nextBool() ? delta : -delta);
      if (v >= 0) options.add(v);
    }
    final list = options.toList()..shuffle();
    return list;
  }

  List<String> generateLetterOptions(String correctLetter) {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final rand = Random();
    final options = <String>{correctLetter};
    final optionCount = widget.grade == 1 ? 4 : 5;
    while (options.length < optionCount) {
      options.add(letters[rand.nextInt(letters.length)]);
    }
    final list = options.toList()..shuffle();
    return list;
  }
}
