import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:english_education/shared/game_grade.dart';
import '../../widgets/text.dart'; // GradientStrokeText

const _asset = 'asset/images';
const _bg = '$_asset/report_bg.png'; // biar konsisten tema
const _closeSvg = '$_asset/close_button.svg';

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.playerName,
    required this.grade,
  });

  final String playerName;
  final GameGrade grade;

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
                  // HEADER: Title + Close
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: GradientStrokeText(
                            text: "REPORT",
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

                  // Info filter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Text(
                      "Name: $playerName   |   Grade: ${_gradeLabel(grade)}",
                      style: const TextStyle(
                        fontFamily: 'ComicNeue',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B220C),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CHALKBOARD
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: _Chalkboard(
                          child: _ReportTable(
                            playerName: playerName,
                            grade: grade,
                          ),
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

/// Papan tulis (tanpa asset): hijau + “kayu” border
class _Chalkboard extends StatelessWidget {
  const _Chalkboard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A2B), // kayu luar
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
          color: const Color(0xFF174F3A), // papan hijau tua
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB47B20), width: 3),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: child,
      ),
    );
  }
}

/// Tabel report (stream Firestore)
class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.playerName, required this.grade});

  final String playerName;
  final GameGrade grade;

  @override
  Widget build(BuildContext context) {
    // final q = FirebaseFirestore.instance
    //     .collection('exercise_results')
    //     .where('userName', isEqualTo: playerName)
    //     .where('grade', isEqualTo: grade.name)
    //     .orderBy('createdAt', descending: true); // mungkin perlu index
    final q = FirebaseFirestore.instance
        .collection('exercise_results')
        .where('userName', isEqualTo: playerName)
        .where('grade', isEqualTo: grade.name);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _chalkMessage("Error loading report: ${snap.error}");
        }
        final docs = snap.data?.docs ?? [];
        docs.sort((a, b) {
          final am = (a.data() as Map<String, dynamic>?) ?? {};
          final bm = (b.data() as Map<String, dynamic>?) ?? {};
          final ad = _ReportTable._pickBestDate(am);
          final bd = _ReportTable._pickBestDate(bm);
          return bd.compareTo(ad); // terbaru di atas
        });

        if (docs.isEmpty) {
          return _chalkMessage(
            "No results yet.\nFinish an exercise to see progress!",
          );
        }

        // Header + rows
        final rows = <_RowData>[];
        for (var i = 0; i < docs.length; i++) {
          final d = docs[i].data() as Map<String, dynamic>? ?? {};
          final name = (d['userName'] ?? '') as String;
          final total = (d['total'] ?? 0) as int;
          final rawScore = (d['score'] ?? 0) as int;
          final percent = (d['percent'] is num)
              ? (d['percent'] as num).toInt()
              : (total > 0 ? ((rawScore / total) * 10).round() : 0);

          // tanggal: createdAt (Timestamp) atau finishedAt (ISO)
          final dt = _pickBestDate(d);
          rows.add(
            _RowData(
              no: i + 1,
              name: name.isEmpty ? playerName : name,
              score: percent, // tampilkan nilai 0..100
              date: _fmtDate(dt),
            ),
          );
        }

        // Scrollable horizontal + vertical
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 640),
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
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Score')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: rows
                      .map(
                        (r) => DataRow(
                          cells: [
                            DataCell(Text('${r.no}')),
                            DataCell(Text(r.name)),
                            DataCell(Text('${r.score}')),
                            DataCell(Text(r.date)),
                          ],
                        ),
                      )
                      .toList(),
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
    // createdAt (Timestamp)
    final createdAt = d['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();

    // finishedAt (ISO string?)
    final finished = d['finishedAt'];
    if (finished is String) {
      final parsed = DateTime.tryParse(finished);
      if (parsed != null) return parsed;
    }

    // startedAt (ISO)
    final started = d['startedAt'];
    if (started is String) {
      final parsed = DateTime.tryParse(started);
      if (parsed != null) return parsed;
    }

    // fallback now
    return DateTime.now();
  }

  static String _fmtDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }
}

class _RowData {
  final int no;
  final String name;
  final int score;
  final String date;
  _RowData({
    required this.no,
    required this.name,
    required this.score,
    required this.date,
  });
}
