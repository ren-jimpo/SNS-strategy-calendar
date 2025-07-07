import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines準拠のタイポグラフィシステム
class AppTypography {
  AppTypography._();

  // San Francisco フォントファミリー
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyText = 'SF Pro Text';

  // Large Title
  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.37,
    height: 1.2,
  );

  // Title 1
  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    height: 1.2,
  );

  // Title 2
  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    height: 1.2,
  );

  // Title 3
  static const TextStyle title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.2,
  );

  // Headline
  static const TextStyle headline = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.3,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.3,
  );

  // Callout
  static const TextStyle callout = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.3,
  );

  // Subhead
  static const TextStyle subhead = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.3,
  );

  // Footnote
  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.3,
  );

  // Caption 1
  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.3,
  );

  // Caption 2
  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.3,
  );

  // ボタン用
  static const TextStyle button = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.3,
  );

  // ナビゲーション用
  static const TextStyle navigationTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.3,
  );

  // タブバー用
  static const TextStyle tabBarItem = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.12,
    height: 1.3,
  );
} 