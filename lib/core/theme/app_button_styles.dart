import 'package:flutter/material.dart';
// adjust path if needed



class AppButtonStyles {
  AppButtonStyles._(); // private constructor (no instantiation)

  // Brand colors (you can later move these to app_colors.dart)
  static const Color lilac = Color(0xFFB57EDC);
  static const Color lilacHover = Color(0xFF9F63C5);

  /// Primary lilac button style
  static ButtonStyle primaryLilacButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) {
        if (states.contains(WidgetState.hovered)) {
          return lilacHover;
        }
        return lilac;
      },
    ),
    foregroundColor:
         WidgetStateProperty.all<Color>(Colors.white),
    elevation:  WidgetStateProperty.resolveWith<double>(
      (states) {
        if (states.contains(WidgetState.hovered)) {
          return 6;
        }
        return 2;
      },
    ),
    shape:  WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textStyle:  WidgetStateProperty.all(
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    ),
  );
}
