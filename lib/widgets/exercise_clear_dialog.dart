// lib/screens/game/widgets/exercise_clear_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';

class ExerciseClearDialog extends StatelessWidget {
  const ExerciseClearDialog({
    super.key,
    required this.playerName,
    required this.score,
    this.total, // optional: kalau mau tampil "x / total"
    this.onBack,
  });

  final String playerName;
  final int score;
  final int? total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Skala dinamis: batasi max width biar nyaman di HP kecil & tablet
    // final badgeW = min(size.width * 0.78, 340.0);
    final badgeW = min(
      size.width * 0.70,
      340.0,
    ); // sebelumnya 0.78     // sedikit dipangkas

    // Rasio PNG badge_clear_exercise (lebar=322, tinggi=294)
    const badgeAspect = 322 / 294; // width / height
    final badgeH = badgeW / badgeAspect;

    // Tombol back dibatasi relatif ke badge
    // final backW = min(180.0, badgeW * 0.45);
    final backW = min(160.0, badgeW * 0.42);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Center(
        child: SizedBox(
          width: badgeW,
          // sediakan sedikit ruang di bawah untuk tombol yang “menggantung”
          height: badgeH + backW * 0.35,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Badge dengan aspect-ratio fix agar teks overlay selalu presisi
              SizedBox(
                width: badgeW,
                height: badgeH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'asset/images/badge_clear_exercise.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Overlay teks: padding pakai FRAKSI dari ukuran badge
                    Positioned.fill(
                      child: Padding(
                        // top: sedikit di bawah pita; bottom: beri ruang bintang
                        padding: EdgeInsets.fromLTRB(
                          badgeW * 0.14, // kiri
                          badgeH * 0.36, // atas
                          badgeW * 0.14, // kanan
                          badgeH * 0.22, // bawah
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                (playerName.isEmpty ? 'Player' : playerName)
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3B220C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                total == null
                                    ? 'SCORE: $score'
                                    : 'SCORE: $score / $total',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B220C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Back (PNG) — selalu proporsional & “nempel” di bawah badge
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'asset/images/btn_back.png',
                    width: backW,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
