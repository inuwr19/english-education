import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:english_education/shared/game_grade.dart';
import '../../widgets/text.dart'; // GradientStrokeText

const _asset = 'asset/images';
const _bg = '$_asset/report_bg.png';
const _closeSvg = '$_asset/close_button.svg';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.initialGrade});
  final GameGrade initialGrade;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late GameGrade _grade;

  @override
  void initState() {
    super.initState();
    _grade = widget.initialGrade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bg, fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: GradientStrokeText(
                            text: "LEADERBOARD",
                            maxFontSize: 42,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SvgPicture.asset(_closeSvg, width: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Grade selector
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final g in GameGrade.values)
                        ChoiceChip(
                          label: Text(_gradeLabel(g)),
                          selected: _grade == g,
                          onSelected: (_) => setState(() => _grade = g),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chalkboard with table
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: _Chalkboard(
                          child: _LeaderboardTable(grade: _grade),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _gradeLabel(GameGrade g) {
    switch (g) {
      case GameGrade.grade1:
        return "Grade 1";
      case GameGrade.grade2:
        return "Grade 2";
      case GameGrade.grade3:
        return "Grade 3";
    }
  }
}

/// papan tulis
class _Chalkboard extends StatelessWidget {
  const _Chalkboard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A2B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF174F3A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB47B20), width: 3),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: child,
      ),
    );
  }
}

/// leaderboard (aggregate per userName)
class _LeaderboardTable extends StatelessWidget {
  const _LeaderboardTable({required this.grade});
  final GameGrade grade;

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('exercise_results')
        .where(
          'grade',
          isEqualTo: grade.name,
        ); // tanpa orderBy → no index needed

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _chalkMessage("Error: ${snap.error}");
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _chalkMessage("Belum ada skor untuk ${grade.name}.");
        }

        // Aggregate per userName
        final Map<String, _LbEntry> map = {};
        for (final doc in docs) {
          final d = (doc.data() as Map<String, dynamic>?) ?? {};
          final name = ((d['userName'] ?? '') as String).trim();
          if (name.isEmpty) continue;

          final total = (d['total'] ?? 0) as int;
          int score = 0;
          if (d['score'] is num) {
            score = (d['score'] as num).toInt();
          } else if (total > 0 && d['rawCorrect'] is num) {
            score = (((d['rawCorrect'] as num) / total) * 100).round();
          }

          final dt = _pickBestDate(d);

          map.update(
            name,
            (old) => old.consume(score, dt),
            ifAbsent: () =>
                _LbEntry(name: name, bestScore: score, attempts: 1, latest: dt),
          );
        }

        final list = map.values.toList()
          ..sort((a, b) {
            final byScore = b.bestScore.compareTo(a.bestScore);
            if (byScore != 0) return byScore;
            return b.latest.compareTo(a.latest);
          });

        final rows = <DataRow>[];
        for (var i = 0; i < list.length; i++) {
          final e = list[i];
          rows.add(
            DataRow(
              cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(e.name)),
                DataCell(Text('${e.bestScore}')),
                DataCell(Text('${e.attempts}')),
                DataCell(Text(_fmtDate(e.latest))),
              ],
            ),
          );
        }

        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 720),
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(.08),
                  ),
                  dataRowColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(.03),
                  ),
                  headingTextStyle: const TextStyle(
                    fontFamily: 'ComicNeue',
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  dataTextStyle: const TextStyle(
                    fontFamily: 'ComicNeue',
                    color: Colors.white,
                  ),
                  columns: const [
                    DataColumn(label: Text('Rank')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Best Score')),
                    DataColumn(label: Text('Attempts')),
                    DataColumn(label: Text('Last Date')),
                  ],
                  rows: rows,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _chalkMessage(String msg) => Center(
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'ComicNeue',
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  );

  static DateTime _pickBestDate(Map<String, dynamic> d) {
    final createdAt = d['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();
    final finished = d['finishedAt'];
    if (finished is String) {
      final parsed = DateTime.tryParse(finished);
      if (parsed != null) return parsed;
    }
    final started = d['startedAt'];
    if (started is String) {
      final parsed = DateTime.tryParse(started);
      if (parsed != null) return parsed;
    }
    return DateTime(2000); // sangat lama agar tak mengalahkan data valid
  }

  static String _fmtDate(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);
}

class _LbEntry {
  _LbEntry({
    required this.name,
    required this.bestScore,
    required this.attempts,
    required this.latest,
  });
  final String name;
  final int bestScore;
  final int attempts;
  final DateTime latest;

  _LbEntry consume(int score, DateTime dt) => _LbEntry(
    name: name,
    bestScore: score > bestScore ? score : bestScore,
    attempts: attempts + 1,
    latest: dt.isAfter(latest) ? dt : latest,
  );
}
