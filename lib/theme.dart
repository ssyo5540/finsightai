import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Colours taken from the FinSight design.
abstract final class Brand {
  static const ink = Color(0xFF111111);
  static const canvas = Color(0xFFF6F5F3);
  static const muted = Color(0xFF6B6B6B);
  static const mutedWarm = Color(0xFF6B5A4E);
  static const faint = Color(0xFFA3A3A3);
  static const hairline = Color(0xFFF0EEEB);
  static const border = Color(0xFFE6E3DF);
  static const chipBorder = Color(0xFFECEAE7);
  static const navInk = Color(0xFF3A3A3A);
  static const navBackground = Color(0xF2E8E6E3);
  static const segment = Color(0xFFECEAE7);
  static const toggleOff = Color(0xFFD9D6D2);

  static const ember = Color(0xFFE8601C);
  static const rust = Color(0xFFB8470F);
  static const oxblood = Color(0xFF7E240A);
  static const brick = Color(0xFF9A3010);
  static const peach = Color(0xFFFFF1E7);
  static const peachBorder = Color(0xFFF6C9A8);
  static const apricot = Color(0xFFFFB386);
  static const green = Color(0xFF1F7A4D);
  static const greenTint = Color(0xFFE7F5EE);
  static const mint = Color(0xFF9BF0BF);
}

/// White at [opacity]; the design layers translucent white over its gradients.
Color glass(double opacity) => Colors.white.withValues(alpha: opacity);

/// CSS `line-height: normal` for Inter (its ascent + descent). Set on every
/// style so text never picks up Material 3's taller line heights.
const interLineHeight = 1.21;

/// Shorthand for the Inter text styles used everywhere in the design.
TextStyle inter(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? spacing,
  double? height,
  bool italic = false,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing ?? 0,
    height: height ?? interLineHeight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );
}

ThemeData buildFinSightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.ember,
    primary: Brand.ink,
    surface: Colors.white,
  );
  // Material 3 adds letter spacing (up to 0.5) and line heights the design
  // doesn't use; reset them so every default text style renders like CSS.
  final textTheme = Typography.material2021(platform: TargetPlatform.iOS).black
      .merge(Typography.englishLike2021)
      .apply(
        fontFamily: 'Inter',
        bodyColor: Brand.ink,
        displayColor: Brand.ink,
      );
  TextStyle? plain(TextStyle? s) =>
      s?.copyWith(letterSpacing: 0, height: interLineHeight);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: TextTheme(
      displayLarge: plain(textTheme.displayLarge),
      displayMedium: plain(textTheme.displayMedium),
      displaySmall: plain(textTheme.displaySmall),
      headlineLarge: plain(textTheme.headlineLarge),
      headlineMedium: plain(textTheme.headlineMedium),
      headlineSmall: plain(textTheme.headlineSmall),
      titleLarge: plain(textTheme.titleLarge),
      titleMedium: plain(textTheme.titleMedium),
      titleSmall: plain(textTheme.titleSmall),
      bodyLarge: plain(textTheme.bodyLarge),
      bodyMedium: plain(textTheme.bodyMedium),
      bodySmall: plain(textTheme.bodySmall),
      labelLarge: plain(textTheme.labelLarge),
      labelMedium: plain(textTheme.labelMedium),
      labelSmall: plain(textTheme.labelSmall),
    ),
    scaffoldBackgroundColor: Brand.canvas,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Brand.ember,
      selectionHandleColor: Brand.ember,
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(primaryColor: Brand.ember),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Brand.ink,
      contentTextStyle: inter(14, weight: FontWeight.w500, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
    ),
  );
}

/// Layout helpers that map the 390 × 844 mockups onto real devices.
extension DesignMetrics on BuildContext {
  /// The mockups assume a 47 pt status bar. Taller ones (Dynamic Island
  /// iPhones use 62 pt) push every top-anchored element down by the
  /// difference so nothing slides under the clock.
  double get topShift =>
      math.max(0, MediaQuery.paddingOf(this).top - 47).toDouble();

  /// Scales a horizontal position drawn on the 390 pt artboard.
  double designX(double x) => x * MediaQuery.sizeOf(this).width / 390;
}
