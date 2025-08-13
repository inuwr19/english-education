import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GradientStrokeText extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final int maxLines;
  final TextAlign textAlign;

  const GradientStrokeText({
    super.key,
    required this.text,
    this.maxFontSize = 96,
    this.maxLines = 2,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke text
        AutoSizeText(
          text,
          style: TextStyle(
            fontSize: maxFontSize,
            fontFamily: 'ComicNeue',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth =
                  3.5 // Slightly reduced stroke width for better readability
              ..color = const Color(0xFF360301),
          ),
          maxLines: maxLines,
          minFontSize: 12, // Increase minimum font size for readability
          textAlign: textAlign,
          overflow: TextOverflow.ellipsis,
          wrapWords: true,
        ),

        // Gradient fill text
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBF56E), // 0%
              Color(0xFFF09538), // 100%
            ],
          ).createShader(bounds),
          child: AutoSizeText(
            text,
            style: TextStyle(
              fontSize: maxFontSize,
              fontFamily: 'ComicNeue',
              color: Colors.white,
            ),
            maxLines: maxLines,
            minFontSize: 12, // Increase minimum font size for readability
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
            wrapWords: true,
          ),
        ),
      ],
    );
  }
}
