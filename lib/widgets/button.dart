import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? minWidth;
  final double? maxWidth;
  final EdgeInsets padding;
  final int maxLines;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.minWidth,
    this.maxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate constraints
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultMaxWidth = maxWidth ?? screenWidth * 0.9;
    final defaultMinWidth = minWidth ?? 120.0;
    final buttonHeight = height ?? (maxLines > 1 ? 80.0 : 70.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Set explicit width if provided, otherwise use constraints
        final finalWidth = width ?? constraints.maxWidth;
        final constrainedWidth = finalWidth.clamp(
          defaultMinWidth,
          defaultMaxWidth,
        );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: constrainedWidth,
            constraints: BoxConstraints(minHeight: buttonHeight),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // SVG Background - stretched to fit content
                SvgPicture.asset(
                  'asset/images/button.svg',
                  width: constrainedWidth,
                  height: buttonHeight,
                  fit: BoxFit.fill,
                ),

                // Content Container
                Container(
                  width: constrainedWidth,
                  padding: padding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constrainedWidth - padding.horizontal - 16,
                      ),
                      child: GradientStrokeText(
                        text: text,
                        maxFontSize: maxLines > 1 ? 24 : 32,
                        maxLines: maxLines,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extension for various button types
extension CustomButtonExtensions on CustomButton {
  // Regular sized button with auto-width
  static Widget standard({
    required String text,
    required VoidCallback onTap,
    double? width,
    double height = 70,
  }) {
    return CustomButton(
      text: text,
      onTap: onTap,
      width: width,
      height: height,
      maxLines: 1,
    );
  }

  // Button for longer text content
  static Widget longText({
    required String text,
    required VoidCallback onTap,
    double? width,
    double? maxWidth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      width: width ?? double.infinity,
      child: CustomButton(
        text: text,
        onTap: onTap,
        height: 90, // Taller to fit more text
        maxWidth: maxWidth,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        maxLines: 2,
      ),
    );
  }

  // Small button for compact options
  static Widget small({required String text, required VoidCallback onTap}) {
    return CustomButton(
      text: text,
      onTap: onTap,
      height: 50,
      minWidth: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
