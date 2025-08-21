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

          // 1) Kanvas desain (bebas pilih, saya pakai 430×900 seperti iPhone 12-ish)
          const double designW = 430;
          const double designH = 900;

          // 2) Semua ukuran/posisi dihitung pakai SISI DESAIN (bukan layar nyata)
          //    Supaya konsisten, lalu discale dengan FittedBox.
          final w = designW;
          final h = designH;

          // ----- ukuran responsif DI ATAS KANVAS DESAIN -----
          // angka-angka ini sama idenya dengan punyamu, tapi berbasis designW/H
          final closeW = (w * 0.10).clamp(36.0, 56.0);
          final smallBtnW = (w * 0.26).clamp(120.0, 200.0);
          final smallBtnH = smallBtnW * 0.58;
          final gapY = max(10.0, smallBtnH * 0.26);

          final famW = (w * 0.42).clamp(180.0, 360.0);
          final reportW = (w * 0.32).clamp(140.0, 240.0);
          final leaderW = (w * 0.30).clamp(130.0, 230.0);
          const bottomGap = 12.0;
          const btnGap = 12.0;

          // ----- posisi cluster segitiga -----
          final clusterCX = w * 0.32;
          final clusterTopBase = max(
            h * 0.10,
            10,
          ); // pad.top “disimulasikan”: 10
          final clusterTop = clusterTopBase + h * 0.06;

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

          double kRightOverlap = 0.55;
          final exerciseLeft = (learningLeft + smallBtnW * kRightOverlap).clamp(
            8.0,
            w - smallBtnW - 8,
          );
          final exerciseTop = playingTop;

          // ----- family & tombol bawah -----
          final famRight = w * 0.05;
          final famBottom = h * 0.16;
          final famLeft = w - famRight - famW;
          final totalBottomW = leaderW + btnGap + reportW;
          final buttonsLeft = (famLeft + (famW - totalBottomW) / 2).clamp(
            8.0,
            w - totalBottomW - 8,
          );
          final buttonsBottom = max(bottomGap, famBottom - 12);

          // 3) COLLISION GUARD (anti tumpuk):
          //    Pastikan cluster segitiga tidak “menabrak” area family+bottom buttons.
          final clusterBottom =
              playingTop +
              smallBtnH; // dua baris: learning + (playing/exercise)
          final bottomReservedTop =
              h -
              (buttonsBottom +
                  max(leaderW, reportW) * 0.45); // kira2 tinggi tombol bawah

          if (clusterBottom > bottomReservedTop) {
            final shiftUp = clusterBottom - bottomReservedTop + 16; // margin
            // geser trio tombol ke atas seperlunya
            final newLearningTop = max(learningTop - shiftUp, pad.top + 10);
            final delta = learningTop - newLearningTop;

            // terapkan shift
            // (pakai var agar mudah diedit bila perlu)
            final _learningTop = newLearningTop;
            final _playingTop = playingTop - delta;
            final _exerciseTop = exerciseTop - delta;

            // tulis ulang variabel final via shadowing (untuk simplicity patch):
            return _ScaledMenu(
              pad: pad,
              designW: designW,
              designH: designH,
              buildChild: (context) => Stack(
                children: [
                  // background tetap di luar (full screen) — kita pasang di bawah
                  // group interaktif:
                  // tombol close
                  Positioned(
                    top: pad.top + 10,
                    right: 12,
                    child: _CloseButton(width: closeW),
                  ),
                  // family
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
                  // trio (LEARNING/PLAYING/EXERCISE) — sudah di-shift
                  Positioned(
                    left: learningLeft,
                    top: _learningTop,
                    child: _SvgButton(
                      assetPath: 'asset/images/learning_button.svg',
                      width: smallBtnW,
                      onTap: () => _navigateTo(context, 'learning'),
                    ),
                  ),
                  Positioned(
                    left: playingLeft,
                    top: _playingTop,
                    child: _SvgButton(
                      assetPath: 'asset/images/playing_button.svg',
                      width: smallBtnW,
                      onTap: () => _navigateTo(context, 'playing'),
                    ),
                  ),
                  Positioned(
                    left: exerciseLeft,
                    top: _exerciseTop,
                    child: _SvgButton(
                      assetPath: 'asset/images/exercise_button.svg',
                      width: smallBtnW,
                      onTap: () => _navigateTo(context, 'exercise'),
                    ),
                  ),
                  // bottom buttons
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
              ),
            );
          }

          // 4) TANPA tabrakan → render normal pada kanvas desain
          return _ScaledMenu(
            pad: pad,
            designW: designW,
            designH: designH,
            buildChild: (context) => Stack(
              children: [
                // tombol close
                Positioned(
                  top: pad.top + 10,
                  right: 12,
                  child: _CloseButton(width: closeW),
                ),
                // family
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
                // trio segitiga
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
                // bottom buttons
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
            ),
          );
        },
      ),
    );
  }
}

// Helpers
/// Widget pembungkus yang menangani scaling + background full-screen.
class _ScaledMenu extends StatelessWidget {
  final EdgeInsets pad;
  final double designW;
  final double designH;
  final WidgetBuilder buildChild;
  const _ScaledMenu({
    required this.pad,
    required this.designW,
    required this.designH,
    required this.buildChild,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background tetap FULL layar
        Positioned.fill(
          child: Image.asset('asset/images/mainmenu_bg.png', fit: BoxFit.cover),
        ),

        // Kanvas desain yang diskalakan proporsional
        Center(
          child: FittedBox(
            fit: BoxFit.contain, // seluruh kanvas masuk layar, tidak terpotong
            child: SizedBox(
              width: designW,
              height: designH,
              child: buildChild(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tombol close yang juga hapus nama & kembali ke welcome
class _CloseButton extends StatelessWidget {
  final double width;
  const _CloseButton({required this.width});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SoundService.instance.tap();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('playerName');
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
      },
      child: SvgPicture.asset('asset/images/close_button.svg', width: width),
    );
  }
}

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
