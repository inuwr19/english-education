import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectGradeScreen extends StatelessWidget {
  const SelectGradeScreen({super.key});

  Future<void> _selectGrade(
    BuildContext context,
    int grade,
    String name,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('players').add({
        'name': name,
        'grade': grade,
        'score': 0,
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(
        context,
        '/main-menu',
        arguments: {'grade': grade, 'playerName': name},
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving grade: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String playerName =
        (ModalRoute.of(context)?.settings.arguments as String?)?.trim() ??
        'Player';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, cons) {
          final w = cons.maxWidth;
          final h = cons.maxHeight;
          final safeTop = MediaQuery.of(context).padding.top;

          // ---- ukuran responsif utama ----
          final titleW = min(w * 0.44, 240.0);
          final titleH = titleW * 0.38; // rasio kira-kira
          final kidH = min(h * 0.28, 180.0); // batasi supaya tak habiskan ruang

          // ruang atas (judul) & bawah (anak)
          final topInset = safeTop + titleH + 16;
          final bottomInset = max(12.0, min(h * 0.10, 36.0));

          final availableH = max(0.0, h - topInset - bottomInset);

          // jarak antar tombol
          final rowGap = min(max(12.0, w * 0.04), 28.0);
          final colGap = min(max(16.0, h * 0.04), 36.0);

          // lebar cluster & ukuran tombol dasar (dibatasi oleh tinggi yg tersedia)
          final clusterW = min(w * 0.82, 560.0);
          final sizeFromWidth = min(max(w * 0.24, 86.0), 136.0);
          final sizeFromHeight = (availableH - colGap) / 2.0;
          final btnSize = max(64.0, min(sizeFromWidth, sizeFromHeight));

          return Stack(
            fit: StackFit.expand,
            children: [
              // BG
              Image.asset('asset/images/welcome_bg.png', fit: BoxFit.cover),

              // Judul “GRADE?”
              Positioned(
                top: safeTop + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'asset/images/grade_text.png',
                    width: titleW,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Anak kiri/kanan (dibatasi tinggi)
              Positioned(
                left: 12,
                bottom: 12,
                child: Image.asset(
                  'asset/images/welcome_kid_left.png',
                  height: kidH,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Image.asset(
                  'asset/images/welcome_kid_right.png',
                  height: kidH,
                  fit: BoxFit.contain,
                ),
              ),

              // Area klaster tombol → dipastikan berada DI BAWAH judul,
              // dan memakai FittedBox supaya auto-scale kalau masih mepet
              Positioned.fill(
                top: topInset,
                bottom: bottomInset,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: clusterW,
                      maxHeight: availableH,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _GradeCoin(
                                asset: 'asset/images/grade1_button.png',
                                size: btnSize,
                                onTap: () =>
                                    _selectGrade(context, 1, playerName),
                              ),
                              SizedBox(width: rowGap),
                              _GradeCoin(
                                asset: 'asset/images/grade2_button.png',
                                size: btnSize,
                                onTap: () =>
                                    _selectGrade(context, 2, playerName),
                              ),
                            ],
                          ),
                          SizedBox(height: colGap),
                          _GradeCoin(
                            asset: 'asset/images/grade3_button.png',
                            size: btnSize,
                            onTap: () => _selectGrade(context, 3, playerName),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GradeCoin extends StatelessWidget {
  const _GradeCoin({
    required this.asset,
    required this.size,
    required this.onTap,
  });

  final String asset;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
