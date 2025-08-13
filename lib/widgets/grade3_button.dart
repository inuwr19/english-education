import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'text.dart';

class Grade3Button extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final EdgeInsets padding;

  const Grade3Button({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final buttonWidth = width ?? (screenWidth - 40);
    final buttonWidth =
        width ?? 180; // fallback kecil; parent biasanya kirim width

    // Ukur tinggi teks yang sebenarnya (max 3 baris)
    final textStyle = const TextStyle(
      fontSize: 24, // selaras dengan GradientStrokeText.maxFontSize ~ 24–26
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    final maxTextWidth = buttonWidth - padding.horizontal;
    final painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: 3,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxTextWidth);

    // “chrome” button (radius/tepi SVG) + padding
    const chromeExtra = 20.0; // ruang tambahan biar napas
    const minHeight = 56.0; // tinggi minimum tombol
    final calcHeight = painter.size.height + padding.vertical + chromeExtra;
    final buttonHeight = calcHeight < minHeight ? minHeight : calcHeight;

    return Container(
      width: buttonWidth,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: buttonHeight,
          child: Stack(
            children: [
              // Background SVG melar mengikuti container
              Positioned.fill(
                child: SvgPicture.asset(
                  'asset/images/button.svg',
                  fit: BoxFit.fill,
                ),
              ),
              // Teks di tengah, wrap sampai 3 baris
              Padding(
                padding: padding,
                child: Center(
                  child: GradientStrokeText(
                    text: text,
                    maxFontSize: 24,
                    maxLines: 3,
                    textAlign: TextAlign.center,
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
