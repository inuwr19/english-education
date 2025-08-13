import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenuScreen extends StatelessWidget {
  final int grade; // 1..3
  final String playerName; // bisa "unknown" (fallback ke prefs)
  static const double kClusterDownFactor =
      0.06; // 6% tinggi layar -> geser seluruh klaster turun
  static const double kRowGapFactor =
      0.26; // 26% dari tinggi tombol -> jarak LEARNING ke bawah

  const MainMenuScreen({
    super.key,
    required this.grade,
    required this.playerName,
  });

  // --- NAV helper ---
  Future<void> navigateTo(BuildContext context, String type) async {
    var name = playerName.trim();
    if (name.isEmpty || name.toLowerCase() == 'unknown') {
      final prefs = await SharedPreferences.getInstance();
      name = (prefs.getString('playerName') ?? '').trim();
      if (name.isEmpty) name = 'Player';
    }
    Navigator.pushNamed(
      context,
      '/$type',
      arguments: {'grade': grade, 'playerName': name},
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('playerName');
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, cons) {
          final pad = MediaQuery.of(context).viewPadding;
          final w = cons.maxWidth;
          final h = cons.maxHeight;

          // ---- ukuran responsif ----
          final closeW = (w * 0.10).clamp(36.0, 56.0);
          final smallBtnW = (w * 0.26).clamp(120.0, 200.0);
          final smallBtnH = smallBtnW * 0.58;

          final gapY = max(10.0, smallBtnH * kRowGapFactor);
          // jarak vertikal antar tombol

          final famW = (w * 0.42).clamp(180.0, 360.0);
          final reportW = (w * 0.34).clamp(150.0, 260.0);

          // ====== KLASTER SEGITIGA (rapat) ======
          // pusat klaster (geser-geser ini kalau mau pindah klaster cepat)
          final clusterCX = w * 0.32; // posisi horizontal klaster
          final clusterTopBase = max(h * 0.10, pad.top + 10);
          final clusterTop = clusterTopBase + h * kClusterDownFactor;

          // tombol atas (LEARNING) tepat di tengah klaster
          final learningLeft = (clusterCX - smallBtnW / 2).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final learningTop = clusterTop;

          // tombol kiri bawah (PLAYING)
          final playingLeft = (learningLeft - smallBtnW * 0.65).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final playingTop = learningTop + smallBtnH + gapY;

          // tombol kanan bawah (EXERCISE) — overlap 45% lebar tombol supaya dekat
          const kRightOverlap = 0.55;
          final exerciseLeft = (learningLeft + smallBtnW * kRightOverlap).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final exerciseTop = playingTop;

          // keluarga & report
          final famRight = w * 0.05;
          final famBottom = h * 0.16;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'asset/images/mainmenu_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // keluarga di belakang tombol
              Positioned(
                right: famRight,
                bottom: famBottom,
                child: IgnorePointer(
                  ignoring: true,
                  child: SvgPicture.asset(
                    'asset/images/mainmenu_family.svg',
                    width: famW,
                  ),
                ),
              ),

              // close
              Positioned(
                top: pad.top + 10,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('playerName');
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome',
                      (_) => false,
                    );
                  },
                  child: SvgPicture.asset(
                    'asset/images/close_button.svg',
                    width: closeW,
                  ),
                ),
              ),

              // ====== tombol segitiga rapat ======
              Positioned(
                left: learningLeft,
                top: learningTop,
                child: _SvgButton(
                  assetPath: 'asset/images/learning_button.svg',
                  width: smallBtnW,
                  onTap: () => navigateTo(context, 'learning'),
                ),
              ),
              Positioned(
                left: playingLeft,
                top: playingTop,
                child: _SvgButton(
                  assetPath: 'asset/images/playing_button.svg',
                  width: smallBtnW,
                  onTap: () => navigateTo(context, 'playing'),
                ),
              ),
              Positioned(
                left: exerciseLeft,
                top: exerciseTop,
                child: _SvgButton(
                  assetPath: 'asset/images/exercise_button.svg',
                  width: smallBtnW,
                  onTap: () => navigateTo(context, 'exercise'),
                ),
              ),

              // report kecil di bawah keluarga
              Positioned(
                right: famRight + (famW - reportW) / 2,
                bottom: max(pad.bottom + 12, famBottom - 12),
                child: _ImageButton(
                  assetPath: 'asset/images/report_button.png',
                  width: reportW,
                  onTap: () => navigateTo(context, 'report'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// helpers
class _SvgButton extends StatelessWidget {
  final String assetPath;
  final double width;
  final VoidCallback onTap;
  const _SvgButton({
    required this.assetPath,
    required this.width,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(assetPath, width: width, fit: BoxFit.contain),
    );
  }
}

class _ImageButton extends StatelessWidget {
  final String assetPath;
  final double width;
  final VoidCallback onTap;
  const _ImageButton({
    required this.assetPath,
    required this.width,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
    );
  }
}
