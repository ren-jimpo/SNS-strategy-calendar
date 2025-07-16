import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataReminders = true;
  bool _weeklyReports = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getSystemGroupedBackground(themeProvider.isDarkMode),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(themeProvider.isDarkMode),
                Expanded(
                  child: ListView(
                    children: [
                      _buildProfileSection(themeProvider.isDarkMode),
                      const SizedBox(height: 20),
                      _buildNotificationSection(themeProvider.isDarkMode),
                      const SizedBox(height: 20),
                      _buildPreferencesSection(themeProvider),
                      const SizedBox(height: 20),
                      _buildDataSection(themeProvider.isDarkMode),
                      const SizedBox(height: 20),
                      _buildSupportSection(themeProvider.isDarkMode),
                      const SizedBox(height: 20),
                      _buildAboutSection(themeProvider.isDarkMode),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.systemGray.withOpacity(0.1),
            AppColors.systemGray4.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.systemGray.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getSeparatorColor(isDarkMode).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.systemGray2, AppColors.systemGray4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.systemGray.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.settings_solid,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '設定',
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.systemGray,
                  ),
                ),
                Text(
                  'アプリ設定・管理',
                  style: AppTypography.body.copyWith(
                    color: AppColors.getSecondaryLabelColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSecondarySystemGroupedBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(
              CupertinoIcons.person_fill,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ユーザー名',
                  style: AppTypography.headline.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.getLabelColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.getSecondaryLabelColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.systemGray,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(bool isDarkMode) {
    return _buildSettingsSection(
      title: '通知設定',
      icon: CupertinoIcons.bell,
      isDarkMode: isDarkMode,
      children: [
        _buildSwitchTile(
          '投稿リマインダー',
          'スケジュール投稿の通知を受け取る',
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
          isDarkMode,
        ),
        _buildSwitchTile(
          'データ入力リマインダー',
          '投稿後のデータ入力時期を通知',
          _dataReminders,
          (value) => setState(() => _dataReminders = value),
          isDarkMode,
        ),
        _buildSwitchTile(
          '週次レポート',
          '毎週月曜日にパフォーマンスレポートを送信',
          _weeklyReports,
          (value) => setState(() => _weeklyReports = value),
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ThemeProvider themeProvider) {
    return _buildSettingsSection(
      title: '表示設定',
      icon: CupertinoIcons.settings,
      isDarkMode: themeProvider.isDarkMode,
      children: [
        _buildSwitchTile(
          'ダークモード',
          '暗いテーマを使用する',
          themeProvider.isDarkMode,
          (value) => themeProvider.setTheme(value),
          themeProvider.isDarkMode,
        ),
        _buildNavigationTile(
          'カレンダー形式',
          '月表示',
          () => _showCalendarFormatDialog(),
          isDarkMode: themeProvider.isDarkMode,
        ),
        _buildNavigationTile(
          'デフォルトKPI目標',
          'いいね数: 100, インプレッション: 2000',
          () => _showDefaultKPIDialog(),
          isDarkMode: themeProvider.isDarkMode,
        ),
      ],
    );
  }

  Widget _buildDataSection(bool isDarkMode) {
    return _buildSettingsSection(
      title: 'データ管理',
      icon: CupertinoIcons.folder,
      isDarkMode: isDarkMode,
      children: [
        _buildNavigationTile(
          'データエクスポート',
          'CSVまたはPDFで出力',
          () => _showExportDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'データインポート',
          '既存データをインポート',
          () => _showImportDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'データバックアップ',
          'クラウドに自動バックアップ',
          () => _showBackupDialog(),
          isDarkMode: isDarkMode,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.systemGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '有効',
              style: AppTypography.caption2.copyWith(
                color: AppColors.systemGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(bool isDarkMode) {
    return _buildSettingsSection(
      title: 'サポート',
      icon: CupertinoIcons.question_circle,
      isDarkMode: isDarkMode,
      children: [
        _buildNavigationTile(
          'ヘルプ・使い方',
          'アプリの使用方法を確認',
          () => _showHelpDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'フィードバック',
          'ご意見・ご要望をお聞かせください',
          () => _showFeedbackDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'お問い合わせ',
          'サポートチームに連絡',
          () => _showContactDialog(),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildAboutSection(bool isDarkMode) {
    return _buildSettingsSection(
      title: 'アプリについて',
      icon: CupertinoIcons.info_circle,
      isDarkMode: isDarkMode,
      children: [
        _buildNavigationTile(
          'バージョン',
          '1.0.0',
          null,
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'プライバシーポリシー',
          '個人情報の取り扱いについて',
          () => _showPrivacyDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          '利用規約',
          'サービス利用規約',
          () => _showTermsDialog(),
          isDarkMode: isDarkMode,
        ),
        _buildNavigationTile(
          'ライセンス',
          'オープンソースライセンス',
          () => _showLicenseDialog(),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.getSecondarySystemGroupedBackground(isDarkMode),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.getLabelColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.getLabelColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.getSecondaryLabelColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    VoidCallback? onTap, {
    Widget? trailing,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: onTap != null 
                          ? AppColors.getLabelColor(isDarkMode)
                          : AppColors.getSecondaryLabelColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.getSecondaryLabelColor(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 8),
              ],
              if (onTap != null)
                Icon(
                  CupertinoIcons.chevron_right,
                  color: AppColors.systemGray,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarFormatDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('カレンダー形式'),
        content: const Text('カレンダー表示形式の設定は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showDefaultKPIDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('デフォルトKPI設定'),
        content: const Text('デフォルトKPI設定機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('データエクスポート'),
        content: const Text('データエクスポート機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('データインポート'),
        content: const Text('データインポート機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('データバックアップ'),
        content: const Text('バックアップ設定は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ヘルプ'),
        content: const Text('ヘルプ機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('フィードバック'),
        content: const Text('フィードバック機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('お問い合わせ'),
        content: const Text('お問い合わせ機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const Text('プライバシーポリシー表示機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('利用規約'),
        content: const Text('利用規約表示機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ライセンス'),
        content: const Text('ライセンス情報表示機能は準備中です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
} 