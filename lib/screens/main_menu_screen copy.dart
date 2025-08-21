import 'dart:math';
import 'package:english_education/shared/route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_education/shared/sound_service.dart';

class MainMenuScreen extends StatefulWidget {
  final int grade; // 1..3
  final String playerName; // bisa 'unknown' / kosong

  const MainMenuScreen({
    super.key,
    required this.grade,
    required this.playerName,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with RouteAware {
  // Tuning layout
  static const double kClusterDownFactor = 0.06; // geser cluster turun
  static const double kRowGapFactor = 0.26; // jarak vertikal antar tombol

  @override
  void initState() {
    super.initState();
    // BGM menu
    // SoundService.instance.playMenuBgm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route); // ⬅️ subscribe
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // ⬅️ unsubscribe
    super.dispose();
  }

  // Dipanggil saat pertama kali route ini masuk stack & tampil
  @override
  void didPush() {
    SoundService.instance.playMenuBgm();
  }

  // Dipanggil saat route di atasnya dipop (balik dari screen lain)
  @override
  void didPopNext() {
    SoundService.instance.playMenuBgm();
  }

  // Dipanggil saat kita push screen lain (menu -> exercise/learning/etc)
  @override
  void didPushNext() {
    // Halus, lalu screen berikut boleh memutar BGM-nya sendiri
    SoundService.instance.fadeOutBgm(dur: const Duration(milliseconds: 150));
  }

  Future<String> _ensureName(String incoming) async {
    final norm = incoming.trim();
    if (norm.isNotEmpty && norm.toLowerCase() != 'unknown') return norm;
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = (prefs.getString('playerName') ?? '').trim();
    return fromPrefs.isEmpty ? 'Player' : fromPrefs;
  }

  Future<void> _navigateTo(BuildContext context, String type) async {
    SoundService.instance.tap(); // sfx klik
    // Boleh skip fadeOut di sini karena sudah ada di didPushNext()
    final name = await _ensureName(widget.playerName);
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/$type',
      arguments: {'grade': widget.grade, 'playerName': name},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, cons) {
          final pad = MediaQuery.of(context).viewPadding;
          final w = cons.maxWidth;
          final h = cons.maxHeight;

          // ----- ukuran responsif -----
          final closeW = (w * 0.10).clamp(36.0, 56.0);
          final smallBtnW = (w * 0.26).clamp(120.0, 200.0);
          final smallBtnH = smallBtnW * 0.58;
          final gapY = max(10.0, smallBtnH * kRowGapFactor);

          final famW = (w * 0.42).clamp(180.0, 360.0);
          final reportW = (w * 0.32).clamp(140.0, 240.0);
          final leaderW = (w * 0.30).clamp(130.0, 230.0);
          const bottomGap = 12.0;
          const btnGap = 12.0;

          // ----- posisi cluster segitiga -----
          final clusterCX = w * 0.32;
          final clusterTopBase = max(h * 0.10, pad.top + 10);
          final clusterTop = clusterTopBase + h * kClusterDownFactor;

          final learningLeft = (clusterCX - smallBtnW / 2).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final learningTop = clusterTop;

          final playingLeft = (learningLeft - smallBtnW * 0.65).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final playingTop = learningTop + smallBtnH + gapY;

          const kRightOverlap = 0.55; // supaya LEARNING–EXERCISE lebih rapat
          final exerciseLeft = (learningLeft + smallBtnW * kRightOverlap).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final exerciseTop = playingTop;

          // ----- family & tombol bawah di-center tepat di bawah family -----
          final famRight = w * 0.05;
          final famBottom = h * 0.16;
          final famLeft = w - famRight - famW;
          final totalBottomW = leaderW + btnGap + reportW;
          final buttonsLeft = (famLeft + (famW - totalBottomW) / 2).clamp(
            8.0,
            w - totalBottomW - 8,
          );
          final buttonsBottom = max(pad.bottom + bottomGap, famBottom - 12);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'asset/images/mainmenu_bg.png',
                  fit: BoxFit.cover,
                ),
              ),

              // family (di belakang tombol)
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

              // tombol close
              Positioned(
                top: pad.top + 10,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    SoundService.instance.tap();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('playerName');
                    if (!mounted) return;
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

              // ====== tombol segitiga (learning/playing/exercise) ======
              Positioned(
                left: learningLeft,
                top: learningTop,
                child: _SvgButton(
                  assetPath: 'asset/images/learning_button.svg',
                  width: smallBtnW,
                  onTap: () => _navigateTo(context, 'learning'),
                ),
              ),
              Positioned(
                left: playingLeft,
                top: playingTop,
                child: _SvgButton(
                  assetPath: 'asset/images/playing_button.svg',
                  width: smallBtnW,
                  onTap: () => _navigateTo(context, 'playing'),
                ),
              ),
              Positioned(
                left: exerciseLeft,
                top: exerciseTop,
                child: _SvgButton(
                  assetPath: 'asset/images/exercise_button.svg',
                  width: smallBtnW,
                  onTap: () => _navigateTo(context, 'exercise'),
                ),
              ),

              // ====== leaderboard + report (center tepat di bawah family) ======
              Positioned(
                left: buttonsLeft,
                bottom: buttonsBottom,
                child: Row(
                  children: [
                    _ImageButton(
                      assetPath: 'asset/images/leaderboard_button.png',
                      width: leaderW,
                      onTap: () => _navigateTo(context, 'leaderboard'),
                    ),
                    const SizedBox(width: btnGap),
                    _ImageButton(
                      assetPath: 'asset/images/report_button.png',
                      width: reportW,
                      onTap: () => _navigateTo(context, 'report'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Helpers
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SvgPicture.asset(assetPath, width: width, fit: BoxFit.contain),
  );
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
  );
}
