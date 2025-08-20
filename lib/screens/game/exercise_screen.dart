// lib/screens/game/exercise_screen.dart
import 'dart:math';
import 'package:english_education/shared/route_observer.dart';
import 'package:english_education/shared/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_education/shared/game_grade.dart';
import '../../widgets/text.dart';
import '../../widgets/exercise_clear_dialog.dart'; // <- pakai dialog eksternal

/// ------------------------------------------------------------
/// CONFIG & CONSTANTS
/// ------------------------------------------------------------
const _asset = 'asset/images';
const _playingBg = '$_asset/playing_bg.png';

const _hPad = 16.0;
const _vPad = 12.0;

/// ------------------------------------------------------------
/// DATA MODEL – satu tipe untuk Exercise: MCQ + optional image
/// ------------------------------------------------------------
class ExerciseQuestion {
  final String prompt; // teks pertanyaan
  final List<String> options; // a/b/c...
  final String answer; // jawaban benar
  final String? imagePath; // opsional

  ExerciseQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
    this.imagePath,
  }) : assert(options.length >= 2 && options.contains(answer));
}

/// ------------------------------------------------------------
/// SCREEN
/// ------------------------------------------------------------
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.grade,
    required this.userName, // bisa kosong; akan diambil dari prefs
    this.questions, // kalau ingin override pool sendiri
  });

  final GameGrade grade;
  final String userName;
  final List<ExerciseQuestion>? questions;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

/// ------------------------------------------------------------
/// G1 LETTER
/// ------------------------------------------------------------
class _G1LetterQ {
  final String imagePath;
  final String incompleteWord;
  final String correctLetter;
  final List<String> options;
  const _G1LetterQ({
    required this.imagePath,
    required this.incompleteWord,
    required this.correctLetter,
    required this.options,
  });
}

List<_G1LetterQ> _g1LetterFixed() => const [
  _G1LetterQ(
    imagePath: '$_asset/tiger.png',
    incompleteWord: '_IGER',
    correctLetter: 'T',
    options: ['C', 'T', 'L'],
  ),
  _G1LetterQ(
    imagePath: '$_asset/apple.png',
    incompleteWord: '_PPLE',
    correctLetter: 'A',
    options: ['A', 'E', 'I'],
  ),
  _G1LetterQ(
    imagePath: '$_asset/lion.png',
    incompleteWord: 'LIO_',
    correctLetter: 'N',
    options: ['N', 'M', 'B'],
  ),
  _G1LetterQ(
    imagePath: '$_asset/ball.png',
    incompleteWord: 'BA_L',
    correctLetter: 'L',
    options: ['L', 'K', 'H'],
  ),
  _G1LetterQ(
    imagePath: '$_asset/duck.png',
    incompleteWord: '_UCK',
    correctLetter: 'D',
    options: ['B', 'C', 'D'],
  ),
];

/// Konversi ke ExerciseQuestion (prompt = incompleteWord)
List<ExerciseQuestion> _g1LetterFixedAsExercise() {
  return _g1LetterFixed()
      .map(
        (q) => ExerciseQuestion(
          prompt: q.incompleteWord,
          options: q.options,
          answer: q.correctLetter,
          imagePath: q.imagePath,
        ),
      )
      .toList();
}

class _ExerciseScreenState extends State<ExerciseScreen> with RouteAware {
  late final List<ExerciseQuestion> _items;
  int _index = 0;
  int _score = 0;
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _items = (widget.questions ?? _buildPool(widget.grade))..shuffle();
    _startedAt = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    SoundService.instance.playExerciseBgm();
  }

  @override
  void didPopNext() {
    SoundService.instance.playExerciseBgm();
  }

  @override
  void didPushNext() {
    SoundService.instance.fadeOutBgm(dur: const Duration(milliseconds: 150));
  }

  // ---------- Question + Helper functions ----------
  // ------------------------------
  // G1 words (untuk letter-fill)
  // ------------------------------
  static const List<String> _g1Words = [
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

  // ------------------------------
  // G2 adjective pools (no-image & image)
  // disederhanakan ke ExerciseQuestion
  // ------------------------------
  List<ExerciseQuestion> _grade2Pool() => [
    // tanpa gambar
    ExerciseQuestion(
      prompt: "The red apple is . . . than the green apple",
      options: const ["sweeter", "tallest", "fastest"],
      answer: "sweeter",
    ),
    ExerciseQuestion(
      prompt: "A feather is . . . than a stone",
      options: const ["lighter", "heavier", "larger"],
      answer: "lighter",
    ),
    ExerciseQuestion(
      prompt: "This puzzle is the . . . of all",
      options: const ["easiest", "more easy", "easy"],
      answer: "easiest",
    ),
    ExerciseQuestion(
      prompt: "My bag is . . . than your bag",
      options: const ["bigger", "biggest", "big"],
      answer: "bigger",
    ),
    ExerciseQuestion(
      prompt: "The turtle is the . . . animal in the race",
      options: const ["slowest", "slower", "slow"],
      answer: "slowest",
    ),

    // bergambar
    ExerciseQuestion(
      prompt: "Kemala's father is . . . than Kemala",
      options: const ["taller", "shorter", "smaller"],
      answer: "taller",
      imagePath: '$_asset/learning_grade2_adjective.jpg',
    ),
    ExerciseQuestion(
      prompt: "There are . . . people in Kemala's family",
      options: const ["three", "four", "five"],
      answer: "four",
      imagePath: '$_asset/learning_grade2_adjective.jpg',
    ),
    ExerciseQuestion(
      prompt: "Kemala's brother is . . . than Kemala",
      options: const ["taller", "shorter", "smaller"],
      answer: "shorter",
      imagePath: '$_asset/learning_grade2_adjective.jpg',
    ),
    ExerciseQuestion(
      prompt: "Kemala's mother is . . . than Kemala's father",
      options: const ["taller", "shorter", "shortest"],
      answer: "shorter",
      imagePath: '$_asset/learning_grade2_adjective.jpg',
    ),
    ExerciseQuestion(
      prompt: "Kemala is . . . than Kemala's sister",
      options: const ["taller", "shorter", "smaller"],
      answer: "smaller",
      imagePath: '$_asset/learning_grade2_adjective.jpg',
    ),
  ]..shuffle();

  // ------------------------------
  // G3 daily activities & prepositions → ExerciseQuestion
  // ------------------------------
  List<ExerciseQuestion> _grade3DailyPool() => [
    ExerciseQuestion(
      prompt: "What is she doing?",
      options: const [
        "Rina is always do home workout",
        "Rina do Home Workout",
        "Rina standing everyday",
        "Rina is playing video games",
      ],
      answer: "Rina do Home Workout",
      imagePath: '$_asset/daily1.png',
    ),
    ExerciseQuestion(
      prompt: "What are they do?",
      options: const [
        "They walked together",
        "They are going back home",
        "They are go to school together",
        "They went to school",
      ],
      answer: "They are go to school together",
      imagePath: '$_asset/daily2.png',
    ),
    ExerciseQuestion(
      prompt: "What is Bima doing?",
      options: const [
        "A. Bima is not like his food ",
        "B. Bima is watching a movie ",
        "C. Bima is really like he lunch meal ",
        "D. Bima is really like his lunch meal",
      ],
      answer: "D. Bima is really like his lunch meal",
      imagePath: '$_asset/daily3.png',
    ),
    ExerciseQuestion(
      prompt: "What is Naura doing?",
      options: const [
        "A. Naura is take a bath",
        "B. Naura are sleep in the bedroom",
        "C. Naura take a shower",
        "D, Naura Playing with her bumble",
      ],
      answer: "A. Naura is take a bath",
      imagePath: '$_asset/daily4.png',
    ),
    ExerciseQuestion(
      prompt: "What Are They Do?",
      options: const [
        "A. My Family are always dinner together",
        "B. My Family Eat our Own dinner",
        "C. Me And My parents are dinnerr together ",
        "D. We are ate dinner Together",
      ],
      answer: "A. My Family are always dinner together",
      imagePath: '$_asset/daily5.png',
    ),
  ]..shuffle();

  List<ExerciseQuestion> _grade3PrepositionPool() => [
    ExerciseQuestion(
      prompt: "Where is the cat?",
      options: const [
        "On the table",
        "Under the table",
        "Beside the table",
        "In the box",
      ],
      answer: "In the box",
      imagePath: '$_asset/prep1.png',
    ),
    ExerciseQuestion(
      prompt: "Where is the ball?",
      options: const [
        "In the box",
        "On the box",
        "Under the box",
        "Next to the box",
      ],
      answer: "In the box",
      imagePath: '$_asset/prep2.png',
    ),
    ExerciseQuestion(
      prompt: "Where is the dog?",
      options: const [
        "Behind the house",
        "In the house",
        "On the roof",
        "Under the house",
      ],
      answer: "Behind the house",
      imagePath: '$_asset/prep3.png',
    ),
    ExerciseQuestion(
      prompt: "Where is the book?",
      options: const [
        "On the shelf",
        "Under the chair",
        "Beside the bed",
        "In the bag",
      ],
      answer: "In the bag",
      imagePath: '$_asset/prep4.png',
    ),
    ExerciseQuestion(
      prompt: "Where is the apple?",
      options: const [
        "On the Box",
        "Under the Box",
        "In the Box",
        "Beside the Box",
      ],
      answer: "On the Box",
      imagePath: '$_asset/prep5.png',
    ),
  ]..shuffle();

  // ------------------------------
  // Helper pembuat soal Grade 1
  // ------------------------------

  // Letter-fill dari words: "_PPLE" dst, 1 huruf hilang (bukan huruf pertama/terakhir)
  List<ExerciseQuestion> _g1MakeLetterFillFromWords({
    int count = 5,
    List<String> pool = _g1Words,
  }) {
    final rand = Random();
    final List<ExerciseQuestion> out = [];
    final words = [...pool]..shuffle();
    int used = 0, i = 0;

    String _randLetter() => String.fromCharCode(65 + rand.nextInt(26)); // A..Z

    while (used < count && i < words.length) {
      final w = words[i++];
      if (w.length < 3) continue;
      final idx = 1 + rand.nextInt(w.length - 2); // hindari 0 & last
      final correct = w[idx];
      final prompt = "${w.substring(0, idx)}_${w.substring(idx + 1)}";

      // bikin opsi: correct + 2 distraktor unik
      final opts = <String>{correct};
      while (opts.length < 3) {
        final d = _randLetter();
        if (d != correct) opts.add(d);
      }

      out.add(
        ExerciseQuestion(
          prompt: prompt,
          options: opts.toList()..shuffle(),
          answer: correct,
          // optional: kalau kamu punya assets gambar per word → isi saja:
          // imagePath: '$_asset/${w.toLowerCase()}.png',
        ),
      );
      used++;
    }
    // fallback kalau pool habis
    while (used < count) {
      final w = pool[rand.nextInt(pool.length)];
      if (w.length < 3) continue;
      final idx = 1 + rand.nextInt(w.length - 2);
      final correct = w[idx];
      final prompt = "${w.substring(0, idx)}_${w.substring(idx + 1)}";
      final opts = <String>{correct};
      while (opts.length < 3) {
        final d = _randLetter();
        if (d != correct) opts.add(d);
      }
      out.add(
        ExerciseQuestion(
          prompt: prompt,
          options: opts.toList()..shuffle(),
          answer: correct,
        ),
      );
      used++;
    }
    return out;
  }

  // Number-word → pilih angka yang benar (opsi angka sebagai string)
  List<ExerciseQuestion> _g1MakeNumberWordQuestions() {
    final rand = Random();
    final pairs = <MapEntry<String, int>>[
      MapEntry("ONE", 1),
      MapEntry("FIVE", 5),
      MapEntry("SEVEN", 7),
      MapEntry("TWENTY", 20),
      MapEntry("NINETY", 90),
      MapEntry("THREE HUNDRED", 300),
      MapEntry("ONE HUNDRED", 100),
      MapEntry("FIFTY", 50),
      MapEntry("TWO", 2),
      MapEntry("EIGHT", 8),
    ]..shuffle();

    // ambil 5 saja biar ringan
    final take = pairs.take(5).toList();

    List<String> _intOptions(int correct, {int count = 3}) {
      final set = <int>{correct};
      while (set.length < count) {
        final delta = rand.nextInt(20) + 1;
        final v = correct + (rand.nextBool() ? delta : -delta);
        if (v >= 0) set.add(v);
      }
      final list = set.toList()..shuffle();
      return list.map((e) => e.toString()).toList();
    }

    return take
        .map(
          (p) => ExerciseQuestion(
            prompt: "Find the number: '${p.key}'",
            options: _intOptions(p.value, count: 3),
            answer: p.value.toString(),
          ),
        )
        .toList();
  }

  // ---------- Pools per grade (contoh) ----------
  List<ExerciseQuestion> _buildPool(GameGrade g) {
    switch (g) {
      case GameGrade.grade1:
        final letterFixed = _g1LetterFixedAsExercise();
        final numberWords = _g1MakeNumberWordQuestions();
        return [...letterFixed, ...numberWords]..shuffle();

      case GameGrade.grade2:
        return _grade2Pool(); // sudah include no-image + image

      case GameGrade.grade3:
        final daily = _grade3DailyPool();
        final prep = _grade3PrepositionPool();
        return [...daily, ...prep]..shuffle();
    }
  }

  // ---------- Answer flow ----------
  void _pick(String selected) {
    final q = _items[_index];
    final isCorrect = selected == q.answer;
    if (isCorrect) {
      _score += 1;
      SoundService.instance.correct(); // ⬅️ benar
    } else {
      SoundService.instance.wrong(); // ⬅️ salah
    }

    if (_index + 1 >= _items.length) {
      _finish();
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _finish() async {
    // Ambil nama dari prefs jika argumen kosong
    final prefs = await SharedPreferences.getInstance();
    final arg = widget.userName.trim().toLowerCase();
    final validArg = arg.isNotEmpty && arg != 'player' && arg != 'unknown';
    final playerName = validArg
        ? widget.userName.trim()
        : (prefs.getString('playerName') ?? 'Player');

    // 🔢 Skor skala 100 (bukan persen, tapi nilai maksimumnya 100)
    final score100 = ((_score / _items.length) * 100).round();

    // Simpan ke Firestore (best-effort)
    try {
      await FirebaseFirestore.instance.collection('exercise_results').add({
        'userName': playerName,
        'grade': widget.grade.name, // "grade1" | "grade2" | "grade3"
        'score': score100, // ✅ skor 0..100
        'rawCorrect': _score, // 🔎 jumlah benar
        'total': _items.length,
        'startedAt': _startedAt.toIso8601String(),
        'finishedAt': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan skor: $e')));
      }
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExerciseClearDialog(
        playerName: playerName,
        score: score100, // ✅ kirim angka 0..100 ke dialog
        onBack: () {
          Navigator.of(context).pop(); // tutup dialog
          Navigator.of(context).maybePop(); // kembali ke menu
        },
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final q = _items[_index];
    final page = _QuestionCard(
      index: _index,
      total: _items.length,
      question: q,
      onPick: _pick,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_playingBg, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(_hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(current: _index + 1, total: _items.length),
                  const SizedBox(height: 8),
                  Expanded(child: page),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// HEADER (judul "EXERCISE!" + skor/progress kecil)
/// ------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.current, required this.total});
  final int current; // nomor soal saat ini (1-based)
  final int total; // total soal

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // judul besar
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: GradientStrokeText(
              text: "EXERCISE!",
              maxFontSize: 42,
              maxLines: 1,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        // badge kecil kanan: progres soal, bukan skor
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Text(
            "Question: $current / $total",
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B220C),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// QUESTION CARD – responsif, seperti contoh layout
/// ------------------------------------------------------------
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.total,
    required this.question,
    required this.onPick,
  });

  final int index;
  final int total;
  final ExerciseQuestion question;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final wide = cons.maxWidth >= 700; // tablet/landscape → row
        final sidePad = EdgeInsets.symmetric(
          horizontal: _hPad,
          vertical: _vPad,
        );

        final prompt = _PromptBlock(number: index + 1, text: question.prompt);

        final options = _OptionsBar(options: question.options, onPick: onPick);

        final image = (question.imagePath ?? '').isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: sidePad,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    question.imagePath!,
                    fit: BoxFit.contain,
                    height: min(220, cons.maxHeight * .35),
                  ),
                ),
              );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [prompt, const SizedBox(height: 12), options],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Align(alignment: Alignment.topRight, child: image),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [image, prompt, const SizedBox(height: 12), options],
          ),
        );
      },
    );
  }
}

class _PromptBlock extends StatelessWidget {
  const _PromptBlock({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_hPad),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        border: Border.all(color: const Color(0xFFE9D9C5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number",
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: 18,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsBar extends StatelessWidget {
  const _OptionsBar({required this.options, required this.onPick});
  final List<String> options;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        for (var i = 0; i < options.length; i++)
          _OptionPill(
            label: String.fromCharCode(97 + i), // a,b,c
            text: options[i],
            onTap: () {
              SoundService.instance.tap();
              onPick(options[i]);
            },
          ),
      ],
    );
  }
}

class _OptionPill extends StatelessWidget {
  const _OptionPill({
    required this.label,
    required this.text,
    required this.onTap,
  });
  final String label;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB25E), width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$label.",
                style: const TextStyle(
                  fontFamily: 'ComicNeue',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(fontFamily: 'ComicNeue', fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
