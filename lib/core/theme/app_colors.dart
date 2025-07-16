import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines準拠のカラーシステム
/// SNS管理プロダクト特有のデザインを反映
class AppColors {
  AppColors._();

  // === Primary Brand Colors (SNS-inspired) ===
  /// メインブランドカラー - SNSのエネルギーを表現するグラデーションブルー
  static const Color primary = Color(0xFF1DA1F2); // Twitter Blue base
  static const Color primaryVariant = Color(0xFF0D7EC7);
  static const Color primaryLight = Color(0xFF5BB4E8);
  
  /// アクセントカラー - Instagram風グラデーション
  static const Color accent = Color(0xFFE1306C); // Instagram Pink
  static const Color accentOrange = Color(0xFFFF8C00); // Instagram Orange
  static const Color accentPurple = Color(0xFF8A3FFC); // Instagram Purple
  
  /// Success/Engagement色 - SNSエンゲージメントを表現
  static const Color engagement = Color(0xFF00D4AA); // TikTok Cyan
  static const Color likes = Color(0xFFFF3040); // Heart Red
  static const Color shares = Color(0xFF25D366); // WhatsApp Green
  static const Color comments = Color(0xFF3897F0); // Facebook Blue

  // === Content Phase Colors ===
  /// Planning Phase - 落ち着いたグレー
  static const Color planning = Color(0xFF8E8E93);
  /// Development Phase - エネルギッシュなオレンジ
  static const Color development = Color(0xFFFF9500);
  /// Launch Phase - 成功を表すブルー
  static const Color launch = Color(0xFF007AFF);
  /// Performance Phase - 成果を表すグリーン
  static const Color performance = Color(0xFF34C759);

  // === Apple System Colors (Light Mode) ===
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemMint = Color(0xFF00C7BE);
  static const Color systemTeal = Color(0xFF30B0C7);
  static const Color systemCyan = Color(0xFF32ADE6);
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D92);
  static const Color systemBrown = Color(0xFFA2845E);
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // === Gradient Colors ===
  /// SNSらしいグラデーション
  static const List<Color> socialGradient = [
    Color(0xFFFF8C00), // Instagram Orange
    Color(0xFFE1306C), // Instagram Pink
    Color(0xFF8A3FFC), // Instagram Purple
  ];
  
  static const List<Color> engagementGradient = [
    Color(0xFF00D4AA), // TikTok Cyan
    Color(0xFF1DA1F2), // Twitter Blue
  ];

  static const List<Color> performanceGradient = [
    Color(0xFF34C759), // Green
    Color(0xFF00C7BE), // Mint
  ];

  // === Label Colors (Light Mode) ===
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0x99000000); // 60% opacity
  static const Color tertiaryLabel = Color(0x4D000000); // 30% opacity
  static const Color quaternaryLabel = Color(0x2D000000); // 18% opacity

  // === Fill Colors (Light Mode) ===
  static const Color systemFill = Color(0x33787880); // 20% opacity
  static const Color secondarySystemFill = Color(0x28787880); // 16% opacity
  static const Color tertiarySystemFill = Color(0x1E787880); // 12% opacity
  static const Color quaternarySystemFill = Color(0x14787880); // 8% opacity

  // === Background Colors (Light Mode) ===
  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);

  // === Grouped Background Colors (Light Mode) ===
  static const Color systemGroupedBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemGroupedBackground = Color(0xFFF2F2F7);

  // === Separator Colors (Light Mode) ===
  static const Color separator = Color(0x49000000); // 29% opacity
  static const Color opaqueSeparator = Color(0xFFC6C6C8);

  // === Link Color ===
  static const Color link = Color(0xFF007AFF);

  // === Error Colors ===
  static const Color error = Color(0xFFFF3B30);
  static const Color errorBackground = Color(0xFFFFEBEE);

  // === Special Colors ===
  static const Color systemGold = Color(0xFFFFD700);

  // === Dark Mode Colors ===
  // Label Colors (Dark Mode)
  static const Color labelDark = Color(0xFFFFFFFF);
  static const Color secondaryLabelDark = Color(0x99FFFFFF); // 60% opacity
  static const Color tertiaryLabelDark = Color(0x4DFFFFFF); // 30% opacity
  static const Color quaternaryLabelDark = Color(0x2DFFFFFF); // 18% opacity

  // Fill Colors (Dark Mode)
  static const Color systemFillDark = Color(0x33787880); // 20% opacity
  static const Color secondarySystemFillDark = Color(0x28787880); // 16% opacity
  static const Color tertiarySystemFillDark = Color(0x1E787880); // 12% opacity
  static const Color quaternarySystemFillDark = Color(0x14787880); // 8% opacity

  // Background Colors (Dark Mode)
  static const Color systemBackgroundDark = Color(0xFF000000);
  static const Color secondarySystemBackgroundDark = Color(0xFF1C1C1E);
  static const Color tertiarySystemBackgroundDark = Color(0xFF2C2C2E);

  // Grouped Background Colors (Dark Mode)
  static const Color systemGroupedBackgroundDark = Color(0xFF000000);
  static const Color secondarySystemGroupedBackgroundDark = Color(0xFF1C1C1E);
  static const Color tertiarySystemGroupedBackgroundDark = Color(0xFF2C2C2E);

  // Separator Colors (Dark Mode)
  static const Color separatorDark = Color(0x59FFFFFF); // 35% opacity
  static const Color opaqueSeparatorDark = Color(0xFF38383A);

  // === Helper Methods ===
  /// フェーズに応じた色を取得
  static Color getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'planning':
        return planning;
      case 'development':
        return development;
      case 'launch':
        return launch;
      case 'performance':
        return performance;
      default:
        return systemGray;
    }
  }

  /// エンゲージメントタイプに応じた色を取得
  static Color getEngagementColor(String type) {
    switch (type.toLowerCase()) {
      case 'likes':
      case 'like':
        return likes;
      case 'shares':
      case 'share':
        return shares;
      case 'comments':
      case 'comment':
        return comments;
      default:
        return engagement;
    }
  }

  /// SNSプラットフォームの色を取得
  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return accent;
      case 'twitter':
      case 'x':
        return primary;
      case 'facebook':
        return Color(0xFF1877F2);
      case 'linkedin':
        return Color(0xFF0077B5);
      case 'tiktok':
        return Color(0xFF000000);
      case 'youtube':
        return systemRed;
      default:
        return systemGray;
    }
  }

  // === Dark Mode Helper Methods ===
  /// ダークモードに応じたラベル色を取得
  static Color getLabelColor(bool isDarkMode) {
    return isDarkMode ? labelDark : label;
  }

  static Color getSecondaryLabelColor(bool isDarkMode) {
    return isDarkMode ? secondaryLabelDark : secondaryLabel;
  }

  static Color getTertiaryLabelColor(bool isDarkMode) {
    return isDarkMode ? tertiaryLabelDark : tertiaryLabel;
  }

  static Color getQuaternaryLabelColor(bool isDarkMode) {
    return isDarkMode ? quaternaryLabelDark : quaternaryLabel;
  }

  /// ダークモードに応じた背景色を取得
  static Color getSystemBackground(bool isDarkMode) {
    return isDarkMode ? systemBackgroundDark : systemBackground;
  }

  static Color getSecondarySystemBackground(bool isDarkMode) {
    return isDarkMode ? secondarySystemBackgroundDark : secondarySystemBackground;
  }

  static Color getTertiarySystemBackground(bool isDarkMode) {
    return isDarkMode ? tertiarySystemBackgroundDark : tertiarySystemBackground;
  }

  /// ダークモードに応じたグループ化背景色を取得
  static Color getSystemGroupedBackground(bool isDarkMode) {
    return isDarkMode ? systemGroupedBackgroundDark : systemGroupedBackground;
  }

  static Color getSecondarySystemGroupedBackground(bool isDarkMode) {
    return isDarkMode ? secondarySystemGroupedBackgroundDark : secondarySystemGroupedBackground;
  }

  static Color getTertiarySystemGroupedBackground(bool isDarkMode) {
    return isDarkMode ? tertiarySystemGroupedBackgroundDark : tertiarySystemGroupedBackground;
  }

  /// ダークモードに応じた区切り線色を取得
  static Color getSeparatorColor(bool isDarkMode) {
    return isDarkMode ? separatorDark : separator;
  }

  static Color getOpaqueSeparatorColor(bool isDarkMode) {
    return isDarkMode ? opaqueSeparatorDark : opaqueSeparator;
  }

  /// ダークモードに応じたフィル色を取得
  static Color getSystemFillColor(bool isDarkMode) {
    return isDarkMode ? systemFillDark : systemFill;
  }

  static Color getSecondarySystemFillColor(bool isDarkMode) {
    return isDarkMode ? secondarySystemFillDark : secondarySystemFill;
  }

  static Color getTertiarySystemFillColor(bool isDarkMode) {
    return isDarkMode ? tertiarySystemFillDark : tertiarySystemFill;
  }

  static Color getQuaternarySystemFillColor(bool isDarkMode) {
    return isDarkMode ? quaternarySystemFillDark : quaternarySystemFill;
  }

  // === Context-based Helper Methods ===
  /// Contextベースのヘルパーメソッド（自動的にダークモードを検出）
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? labelDark : label;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? secondaryLabelDark : secondaryLabel;
  }
  
  static Color getTertiaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? tertiaryLabelDark : tertiaryLabel;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? systemGroupedBackgroundDark : systemGroupedBackground;
  }
  
  static Color getCardBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? secondarySystemGroupedBackgroundDark : secondarySystemGroupedBackground;
  }
  
  static Color getSystemBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? systemBackgroundDark : systemBackground;
  }
  
  static Color getSeparator(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? separatorDark : separator;
  }
} 