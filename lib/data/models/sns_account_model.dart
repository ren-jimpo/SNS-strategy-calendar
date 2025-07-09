import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// SNSプラットフォーム
enum SNSPlatform {
  instagram('Instagram', 'instagram'),
  x('X (Twitter)', 'x'),
  youtube('YouTube', 'youtube'),
  tiktok('TikTok', 'tiktok'),
  facebook('Facebook', 'facebook'),
  linkedin('LinkedIn', 'linkedin');

  const SNSPlatform(this.displayName, this.key);
  final String displayName;
  final String key;
}

/// SNSアカウント情報
class SNSAccount {
  final String id;
  final SNSPlatform platform;
  final String username;
  final String displayName;
  final String? profileImageUrl;
  final String? description;
  final bool isActive;
  final DateTime connectedAt;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> metadata; // プラットフォーム固有の情報

  const SNSAccount({
    required this.id,
    required this.platform,
    required this.username,
    required this.displayName,
    this.profileImageUrl,
    this.description,
    this.isActive = true,
    required this.connectedAt,
    this.lastSyncAt,
    this.metadata = const {},
  });

  /// プラットフォームの色を取得
  Color get platformColor {
    switch (platform) {
      case SNSPlatform.instagram:
        return const Color(0xFFE4405F);
      case SNSPlatform.x:
        return const Color(0xFF1DA1F2);
      case SNSPlatform.youtube:
        return const Color(0xFFFF0000);
      case SNSPlatform.tiktok:
        return const Color(0xFF000000);
      case SNSPlatform.facebook:
        return const Color(0xFF1877F2);
      case SNSPlatform.linkedin:
        return const Color(0xFF0077B5);
    }
  }

  /// プラットフォームのアイコンを取得
  IconData get platformIcon {
    switch (platform) {
      case SNSPlatform.instagram:
        return CupertinoIcons.camera_fill;
      case SNSPlatform.x:
        return CupertinoIcons.chat_bubble_text_fill;
      case SNSPlatform.youtube:
        return CupertinoIcons.play_rectangle_fill;
      case SNSPlatform.tiktok:
        return CupertinoIcons.music_note;
      case SNSPlatform.facebook:
        return CupertinoIcons.person_3_fill;
      case SNSPlatform.linkedin:
        return CupertinoIcons.briefcase_fill;
    }
  }

  SNSAccount copyWith({
    String? id,
    SNSPlatform? platform,
    String? username,
    String? displayName,
    String? profileImageUrl,
    String? description,
    bool? isActive,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
  }) {
    return SNSAccount(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// アカウント管理サービス（将来のDB連携用）
class AccountManager {
  static List<SNSAccount> _accounts = [];
  static String? _selectedAccountId;

  /// アカウント一覧を取得
  static List<SNSAccount> get accounts => List.unmodifiable(_accounts);

  /// アクティブなアカウント一覧を取得
  static List<SNSAccount> get activeAccounts => 
      _accounts.where((account) => account.isActive).toList();

  /// 選択中のアカウント
  static SNSAccount? get selectedAccount => 
      _selectedAccountId != null 
          ? _accounts.firstWhere((account) => account.id == _selectedAccountId)
          : null;

  /// 全アカウント表示モードかどうか
  static bool get isShowingAllAccounts => _selectedAccountId == null;

  /// アカウントを選択
  static void selectAccount(String? accountId) {
    _selectedAccountId = accountId;
  }

  /// 全アカウント表示モードに切り替え
  static void showAllAccounts() {
    _selectedAccountId = null;
  }

  /// アカウントを追加
  static void addAccount(SNSAccount account) {
    _accounts.add(account);
  }

  /// アカウントを削除
  static void removeAccount(String accountId) {
    _accounts.removeWhere((account) => account.id == accountId);
    if (_selectedAccountId == accountId) {
      _selectedAccountId = null;
    }
  }

  /// モックアカウントを生成
  static void generateMockAccounts() {
    _accounts = [
      SNSAccount(
        id: 'instagram_1',
        platform: SNSPlatform.instagram,
        username: '@my_brand_official',
        displayName: 'MyBrand Official',
        profileImageUrl: null,
        description: 'ブランド公式アカウント',
        connectedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SNSAccount(
        id: 'x_1',
        platform: SNSPlatform.x,
        username: '@mybrand_jp',
        displayName: 'MyBrand Japan',
        profileImageUrl: null,
        description: '日本向けアカウント',
        connectedAt: DateTime.now().subtract(const Duration(days: 25)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SNSAccount(
        id: 'youtube_1',
        platform: SNSPlatform.youtube,
        username: 'MyBrand Channel',
        displayName: 'MyBrand公式チャンネル',
        profileImageUrl: null,
        description: '製品解説・チュートリアル',
        connectedAt: DateTime.now().subtract(const Duration(days: 20)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
} 