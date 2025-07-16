import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Apple Human Interface Guidelines準拠のテーマシステム
class AppTheme {
  AppTheme._();

  /// ライトテーマ
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.systemGroupedBackground,
    cardColor: AppColors.secondarySystemGroupedBackground,
    dividerColor: AppColors.separator,
    
    // カラースキーム
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.systemGray,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.secondarySystemGroupedBackground,
      onSurface: AppColors.label,
    ),

    // テキストテーマ
    textTheme: const TextTheme(
      displayLarge: AppTypography.largeTitle,
      displayMedium: AppTypography.title1,
      displaySmall: AppTypography.title2,
      headlineLarge: AppTypography.title3,
      headlineMedium: AppTypography.headline,
      headlineSmall: AppTypography.headline,
      titleLarge: AppTypography.title3,
      titleMedium: AppTypography.headline,
      titleSmall: AppTypography.subhead,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.callout,
      bodySmall: AppTypography.subhead,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.footnote,
      labelSmall: AppTypography.caption1,
    ),

    // AppBarテーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.systemGroupedBackground,
      foregroundColor: AppColors.label,
      elevation: 0,
      titleTextStyle: AppTypography.navigationTitle,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColors.primary,
        size: 22,
      ),
    ),

    // BottomNavigationBarテーマ
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.systemGray,
      selectedLabelStyle: AppTypography.tabBarItem,
      unselectedLabelStyle: AppTypography.tabBarItem,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ElevatedButtonテーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
      ),
    ),

    // TextButtonテーマ
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.button,
      ),
    ),

    // OutlinedButtonテーマ
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
      ),
    ),

    // InputDecorationテーマ
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.tertiarySystemBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemGray4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemGray4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppTypography.body.copyWith(color: AppColors.tertiaryLabel),
    ),

    // CardTheme
    cardTheme: const CardThemeData(
      color: AppColors.secondarySystemGroupedBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  /// ダークテーマ
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.systemGroupedBackgroundDark,
    cardColor: AppColors.secondarySystemGroupedBackgroundDark,
    dividerColor: AppColors.separatorDark,
    
    // カラースキーム
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.systemGray,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.secondarySystemGroupedBackgroundDark,
      onSurface: AppColors.labelDark,
    ),

    // テキストテーマ（ダーク用）
    textTheme: const TextTheme(
      displayLarge: AppTypography.largeTitle,
      displayMedium: AppTypography.title1,
      displaySmall: AppTypography.title2,
      headlineLarge: AppTypography.title3,
      headlineMedium: AppTypography.headline,
      headlineSmall: AppTypography.headline,
      titleLarge: AppTypography.title3,
      titleMedium: AppTypography.headline,
      titleSmall: AppTypography.subhead,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.callout,
      bodySmall: AppTypography.subhead,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.footnote,
      labelSmall: AppTypography.caption1,
    ).apply(
      bodyColor: AppColors.labelDark,
      displayColor: AppColors.labelDark,
    ),

    // AppBarテーマ（ダーク）
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.systemGroupedBackgroundDark,
      foregroundColor: AppColors.labelDark,
      elevation: 0,
      titleTextStyle: AppTypography.navigationTitle,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColors.primary,
        size: 22,
      ),
    ),

    // BottomNavigationBarテーマ（ダーク）
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.systemGray,
      selectedLabelStyle: AppTypography.tabBarItem,
      unselectedLabelStyle: AppTypography.tabBarItem,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ElevatedButtonテーマ（ダーク）
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
      ),
    ),

    // TextButtonテーマ（ダーク）
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.button,
      ),
    ),

    // OutlinedButtonテーマ（ダーク）
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
      ),
    ),

    // InputDecorationテーマ（ダーク）
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.tertiarySystemBackgroundDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemGray4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.systemGray4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppTypography.body.copyWith(color: AppColors.tertiaryLabelDark),
    ),

    // CardTheme（ダーク）
    cardTheme: const CardThemeData(
      color: AppColors.secondarySystemGroupedBackgroundDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
} 