// lib/screens/playing_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/text.dart';

/// =======================
/// CONSTANTS
/// =======================
const int kMaxLives = 2;
const double kOuterPad = 12;
const double kGap = 8;

const double kKidsHeight = 100; // tinggi ilustrasi kids (untuk padding aman)
const double kBarHeight = 44; // tinggi bar

const double kBubbleOffsetX = 54; // geser ke kanan dari tepi kiri
const double kBubbleOverlapOnKids =
    22; // seberapa jauh gelembung “turun” menimpa area kids

const _assetBase = 'asset/images';

class _A {
  static const bg = '$_assetBase/playing_bg.png';
  static const kids = '$_assetBase/playing_kids.svg';
  static const progressIcon = '$_assetBase/progress_icon.svg';
  static const healthIcon = '$_assetBase/health_icon.svg';
}

/// =======================
/// MODELS
/// =======================
enum GameGrade { grade1, grade2, grade3 }

enum QuestionKind { number, letter }

class NumberQuestion {
  final String numberWord;
  final List<int> options;
  final int answer;
  NumberQuestion({
    required this.numberWord,
    required this.options,
    required this.answer,
  }) : assert(options.length >= 2 && options.contains(answer));
}

class LetterQuestion {
  final String imagePath;
  final String incompleteWord;
  final String correctLetter;
  final List<String> options;
  LetterQuestion({
    required this.imagePath,
    required this.incompleteWord,
    required this.correctLetter,
    required this.options,
  }) : assert(options.length >= 2 && options.contains(correctLetter));
}

/// Polymorphic wrapper
class _Item {
  final QuestionKind kind;
  final NumberQuestion? number;
  final LetterQuestion? letter;
  const _Item.number(this.number) : kind = QuestionKind.number, letter = null;
  const _Item.letter(this.letter) : kind = QuestionKind.letter, number = null;
}

/// =======================
/// SCREEN
/// =======================
class PlayingScreen extends StatefulWidget {
  const PlayingScreen({
    super.key,
    this.grade = GameGrade.grade1,
    this.g1Numbers,
    this.g1Letters,
  });

  final GameGrade grade;
  final List<NumberQuestion>? g1Numbers;
  final List<LetterQuestion>? g1Letters;

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  late final List<_Item> _items;
  int _index = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(widget);
  }

  List<_Item> _buildItems(PlayingScreen w) {
    final numbers = w.g1Numbers ?? _demoNumberQuestions();
    final letters = w.g1Letters ?? _demoLetterQuestions();
    return <_Item>[
      for (final q in numbers) _Item.number(q),
      for (final q in letters) _Item.letter(q),
    ];
  }

  double get _progress {
    final total = _items.length;
    if (total == 0) return 0.0;
    return (_index / total).clamp(0.0, 1.0);
  }

  int get _livesLeft => max(0, kMaxLives - _wrongCount);

  void _onAnswer(bool correct) {
    if (!mounted) return;
    if (!correct) {
      setState(() => _wrongCount++);
      if (_wrongCount >= kMaxLives) _showEndDialog(false);
      return;
    }
    if (_index + 1 >= _items.length) {
      _showEndDialog(true);
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _showEndDialog(bool win) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(win ? 'Great job! 🎉' : 'Try again!'),
        content: Text(
          win ? 'Kamu menyelesaikan semua soal.' : 'Kesempatan salah habis.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (win) Navigator.of(context).maybePop();
              setState(() {
                _index = 0;
                _wrongCount = 0;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions available')),
      );
    }
    final item = _items[_index];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(_A.bg, fit: BoxFit.cover),

            Column(
              children: [
                const SizedBox(height: kGap),
                _TopBars(
                  progress: _progress,
                  livesLeft: _livesLeft,
                  maxLives: kMaxLives,
                ),
                const SizedBox(height: kGap),

                Expanded(
                  child: switch (item.kind) {
                    QuestionKind.number => _Grade1NumberView(
                      q: item.number!,
                      seed: _index,
                      onPick: (v) => _onAnswer(v == item.number!.answer),
                    ),
                    QuestionKind.letter => _Grade1LetterView(
                      q: item.letter!,
                      onPick: (v) => _onAnswer(v == item.letter!.correctLetter),
                    ),
                  },
                ),
              ],
            ),

            const Positioned(left: 8, bottom: 8, child: _KidsDecoration()),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Demo data
  List<NumberQuestion> _demoNumberQuestions() => [
    NumberQuestion(numberWord: 'FIVE', options: const [9, 3, 5, 8], answer: 5),
    NumberQuestion(numberWord: 'TWO', options: const [2, 7, 1, 6], answer: 2),
    NumberQuestion(numberWord: 'NINE', options: const [5, 4, 9, 8], answer: 9),
    NumberQuestion(numberWord: 'THREE', options: const [3, 1, 0, 7], answer: 3),
    NumberQuestion(numberWord: 'EIGHT', options: const [6, 8, 5, 2], answer: 8),
  ];

  List<LetterQuestion> _demoLetterQuestions() => [
    LetterQuestion(
      imagePath: '$_assetBase/tiger.png',
      incompleteWord: '_IGER',
      correctLetter: 'T',
      options: const ['C', 'T', 'L'],
    ),
    LetterQuestion(
      imagePath: '$_assetBase/apple.png',
      incompleteWord: '_PPLE',
      correctLetter: 'A',
      options: const ['A', 'E', 'I'],
    ),
    LetterQuestion(
      imagePath: '$_assetBase/lion.png',
      incompleteWord: 'LIO_',
      correctLetter: 'N',
      options: const ['N', 'M', 'B'],
    ),
    LetterQuestion(
      imagePath: '$_assetBase/ball.png',
      incompleteWord: 'BA_L',
      correctLetter: 'L',
      options: const ['L', 'K', 'H'],
    ),
    LetterQuestion(
      imagePath: '$_assetBase/duck.png',
      incompleteWord: '_UCK',
      correctLetter: 'D',
      options: const ['B', 'C', 'D'],
    ),
  ];
}

/// =======================
/// TOP BARS (ikon dekat bar)
/// =======================
class _TopBars extends StatelessWidget {
  const _TopBars({
    required this.progress,
    required this.livesLeft,
    required this.maxLives,
  });

  final double progress; // 0..1
  final int livesLeft;
  final int maxLives;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kOuterPad),
      child: Row(
        children: [
          Expanded(
            child: _BadgeBar(
              iconAsset: _A.progressIcon,
              fraction: progress.clamp(0, 1),
              height: kBarHeight,
              fillColor: const Color(0xFFFFCE55),
              strokeColor: const Color(0xFFDB8686),
              backgroundColor: Colors.white,
              iconWidth: 52,
              gap: 0, // <— jarak ikon–bar dipersempit
            ),
          ),
          const SizedBox(width: kOuterPad),
          Expanded(
            child: _BadgeBar(
              iconAsset: _A.healthIcon,
              fraction: (livesLeft / maxLives).clamp(0, 1),
              height: kBarHeight,
              fillColor: const Color(0xFFEE3F6C),
              strokeColor: const Color(0xFFDB8686),
              backgroundColor: Colors.white,
              iconWidth: 52,
              gap: 0, // <— jarak ikon–bar dipersempit
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeBar extends StatelessWidget {
  const _BadgeBar({
    required this.iconAsset,
    required this.fraction,
    required this.height,
    required this.fillColor,
    required this.strokeColor,
    required this.backgroundColor,
    this.iconWidth = 56,
    this.gap = 4,
    this.strokePx = 3.5,
  });

  final String iconAsset;
  final double fraction;
  final double height;
  final double iconWidth;
  final double gap;
  final double strokePx;
  final Color fillColor;
  final Color strokeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, cons) {
          final trackLeft = iconWidth + gap;
          final trackWidth = (cons.maxWidth - trackLeft).clamp(
            0.0,
            cons.maxWidth,
          );
          final radius = height / 2;
          final stroke = strokePx;
          final fillWidth = trackWidth * fraction.clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: iconWidth,
                height: height,
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    height: height * 1.05, // tidak terlalu besar
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: trackLeft,
                top: 0,
                width: trackWidth,
                height: height,
                child: CustomPaint(
                  painter: _TrackPainter(
                    radius: radius,
                    stroke: stroke,
                    strokeColor: strokeColor,
                    bgColor: backgroundColor,
                  ),
                ),
              ),
              Positioned(
                left: trackLeft + stroke,
                top: stroke,
                width: max(0, fillWidth - 2 * stroke),
                height: max(0, height - 2 * stroke),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius - stroke / 2),
                  child: Container(color: fillColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.radius,
    required this.stroke,
    required this.strokeColor,
    required this.bgColor,
  });

  final double radius;
  final double stroke;
  final Color strokeColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(radius);
    final rrect = RRect.fromLTRBR(0, 0, size.width, size.height, r);
    final paintBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawRRect(rrect, paintBg);
    canvas.drawRRect(rrect.deflate(stroke / 2), paintStroke);
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.radius != radius ||
      old.stroke != stroke ||
      old.strokeColor != strokeColor ||
      old.bgColor != bgColor;
}

/// =======================
/// GRADE 1: Number
///  - Bubble gabung dengan kata soal
///  - Opsi diacak hanya di sisi kanan
/// =======================
class _Grade1NumberView extends StatelessWidget {
  const _Grade1NumberView({
    required this.q,
    required this.seed,
    required this.onPick,
  });
  final NumberQuestion q;
  final int seed;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kOuterPad, kGap, kOuterPad, 0),
      child: LayoutBuilder(
        builder: (context, cons) {
          final headerMaxWidth = min(320.0, cons.maxWidth * 0.6);

          return Stack(
            children: [
              // opsi angka: hanya di area kanan (55% .. 95% dari lebar)
              Positioned.fill(
                child: _RightSideScatteredOptions(
                  options: q.options,
                  seed: seed,
                  onPick: onPick,
                ),
              ),

              // bubble + kata soal di dekat kids
              Positioned(
                left: kBubbleOffsetX,
                // turunkan sedikit supaya menempel ke kepala/mulut kids
                bottom: kKidsHeight - kBubbleOverlapOnKids,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: headerMaxWidth),
                  child: _NumberPromptBubble(text: q.numberWord),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumberPromptBubble extends StatelessWidget {
  const _NumberPromptBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFB567),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9B3E10), width: 3),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Let's find the number",
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: 14,
                  color: Color(0xFF3B220C),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              // kata soal di dalam bubble, skala otomatis
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: GradientStrokeText(
                  text: text,
                  maxFontSize: 36,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 14,
          bottom: -10,
          child: Transform.rotate(
            angle: -0.15,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CustomPaint(
                painter: _TrianglePainter(
                  color: const Color(0xFF9B3E10),
                  fill: const Color(0xFFFFB567),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RightSideScatteredOptions extends StatelessWidget {
  const _RightSideScatteredOptions({
    required this.options,
    required this.seed,
    required this.onPick,
  });

  final List<int> options;
  final int seed;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final rnd = Random(seed + 2024);
        // Area kanan
        final leftBound = cons.maxWidth * 0.55;
        final rightBound = cons.maxWidth - 8;
        final topBound = 8.0;
        final bottomBound = cons.maxHeight - 8.0;

        const tokenW = 84.0, tokenH = 60.0;

        // anchor grid di kanan, lalu diacak
        final cols = 2;
        final rows = 3;
        final anchors = <Offset>[];
        for (var r = 0; r < rows; r++) {
          for (var c = 0; c < cols; c++) {
            final x = leftBound + (c + 0.5) * ((rightBound - leftBound) / cols);
            final y = topBound + (r + 0.5) * ((bottomBound - topBound) / rows);
            anchors.add(Offset(x, y));
          }
        }
        anchors.shuffle(rnd);

        final children = <Widget>[];
        for (var i = 0; i < options.length; i++) {
          final a = anchors[i % anchors.length];
          // jitter kecil biar tidak terlalu rapih
          final dx = (rnd.nextDouble() - 0.5) * 24;
          final dy = (rnd.nextDouble() - 0.5) * 18;

          var left = a.dx + dx - tokenW / 2;
          var top = a.dy + dy - tokenH / 2;

          left = left.clamp(leftBound, rightBound - tokenW);
          top = top.clamp(topBound, bottomBound - tokenH);

          children.add(
            Positioned(
              left: left,
              top: top,
              width: tokenW,
              height: tokenH,
              child: _NumberToken(
                n: options[i],
                onTap: () => onPick(options[i]),
              ),
            ),
          );
        }

        return Stack(children: children);
      },
    );
  }
}

/// =======================
/// GRADE 1: Letter (board kanan, bubble dekat kids kiri-bawah)
/// =======================
class _Grade1LetterView extends StatelessWidget {
  const _Grade1LetterView({required this.q, required this.onPick});
  final LetterQuestion q;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kOuterPad, kGap, kOuterPad, 0),
      child: LayoutBuilder(
        builder: (context, cons) {
          // board tidak memakan seluruh lebar agar ruang kiri kosong utk kids/bubble
          final boardMaxWidth = (cons.maxWidth * 0.62).clamp(260.0, 520.0);
          // tinggi row opsi adaptif supaya tidak mepet di layar kecil
          final optionsRowHeight = min(90.0, cons.maxHeight * 0.18);

          return Stack(
            children: [
              // ===== konten utama (papan kanan + opsi di bawah) =====
              Positioned.fill(
                child: Column(
                  children: [
                    // area papan di kanan
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: boardMaxWidth),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF176142),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFB24C2C),
                                  width: 6,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              // >>> Perubahan utama: isi papan fleksibel
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (q.imagePath.isNotEmpty) ...[
                                    Flexible(
                                      flex: 3,
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset(q.imagePath),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Flexible(
                                    flex: 2,
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                        child: GradientStrokeText(
                                          text: q.incompleteWord,
                                          maxFontSize: 48,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: kGap),

                    // opsi huruf
                    // opsi huruf (NEW) — lebar mengikuti papan, diratakan kanan & di-centrer di bawah papan
                    Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: boardMaxWidth),
                        child: SizedBox(
                          height: optionsRowHeight,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    var i = 0;
                                    i < q.options.length;
                                    i++
                                  ) ...[
                                    _LetterCapsule(
                                      text: q.options[i],
                                      onTap: () => onPick(q.options[i]),
                                    ),
                                    if (i != q.options.length - 1)
                                      const SizedBox(width: 12),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== bubble di kiri-bawah dekat kids (overlay) =====
              const Positioned(
                left: kBubbleOffsetX,
                bottom: kKidsHeight - kBubbleOverlapOnKids,
                child: _SpeechBubble(text: "Can you help me?", maxWidth: 180),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumberToken extends StatelessWidget {
  const _NumberToken({required this.n, required this.onTap});
  final int n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.90),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB47B20), width: 2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 2),
              color: Colors.black12,
            ),
          ],
        ),
        child: GradientStrokeText(text: '$n', maxFontSize: 40, maxLines: 1),
      ),
    );
  }
}

class _LetterCapsule extends StatelessWidget {
  const _LetterCapsule({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE2A8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB47B20), width: 2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 2),
              color: Colors.black12,
            ),
          ],
        ),
        child: GradientStrokeText(text: text, maxFontSize: 36, maxLines: 1),
      ),
    );
  }
}

/// =======================
/// Reusable UI
/// =======================
class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text, this.maxWidth = 200});
  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB567),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9B3E10), width: 3),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: 14,
                color: Color(0xFF3B220C),
                height: 1.2,
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: -10,
            child: Transform.rotate(
              angle: -0.15,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _TrianglePainter(
                    color: const Color(0xFF9B3E10),
                    fill: const Color(0xFFFFB567),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color, required this.fill});
  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color;
    final paint = Paint()..color = fill;
    canvas.drawPath(p, paint);
    canvas.drawPath(p, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KidsDecoration extends StatelessWidget {
  const _KidsDecoration();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(_A.kids, height: kKidsHeight);
  }
}
