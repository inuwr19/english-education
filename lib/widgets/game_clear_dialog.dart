// lib/widgets/game_clear_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';

Future<void> showGameClearDialog({
  required BuildContext context,
  required VoidCallback onBack,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => _GameClearDialog(onBack: onBack),
  );
}

class _GameClearDialog extends StatelessWidget {
  const _GameClearDialog({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          // Keep dialog inside the viewport on any phone
          child: FractionallySizedBox(
            widthFactor: 0.90, // take up to 90% of screen width
            heightFactor: 0.86, // take up to 86% of screen height
            child: LayoutBuilder(
              builder: (context, cons) {
                // Size pieces from available space (no hard-coded heights)
                final gap = min(20.0, cons.maxHeight * 0.03);
                final badgeMaxH =
                    cons.maxHeight * 0.70; // leave room for button
                final btnH = min(64.0, cons.maxHeight * 0.12);

                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: min(24.0, cons.maxWidth * 0.05),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge image scales down to fit
                      SizedBox(
                        height: badgeMaxH,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset('asset/images/badge_clear.png'),
                        ),
                      ),
                      SizedBox(height: gap),
                      // Back button PNG, also scales
                      GestureDetector(
                        onTap: onBack,
                        child: SizedBox(
                          height: btnH,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset('asset/images/btn_back.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
