import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _dataReminders = true;
  bool _weeklyReports = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          _buildProfileSection(),
          const SizedBox(height: 20),
          _buildNotificationSection(),
          const SizedBox(height: 20),
          _buildPreferencesSection(),
          const SizedBox(height: 20),
          _buildDataSection(),
          const SizedBox(height: 20),
          _buildSupportSection(),
          const SizedBox(height: 20),
          _buildAboutSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.systemGroupedBackground,
      elevation: 0,
      title: Text(
        '設定',
        style: AppTypography.navigationTitle,
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.secondaryLabel,
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

  Widget _buildNotificationSection() {
    return _buildSettingsSection(
      title: '通知設定',
      icon: CupertinoIcons.bell,
      children: [
        _buildSwitchTile(
          '投稿リマインダー',
          'スケジュール投稿の通知を受け取る',
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
        ),
        _buildSwitchTile(
          'データ入力リマインダー',
          '投稿後のデータ入力時期を通知',
          _dataReminders,
          (value) => setState(() => _dataReminders = value),
        ),
        _buildSwitchTile(
          '週次レポート',
          '毎週月曜日にパフォーマンスレポートを送信',
          _weeklyReports,
          (value) => setState(() => _weeklyReports = value),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSettingsSection(
      title: '表示設定',
      icon: CupertinoIcons.settings,
      children: [
        _buildSwitchTile(
          'ダークモード',
          '暗いテーマを使用する',
          _darkMode,
          (value) => setState(() => _darkMode = value),
        ),
        _buildNavigationTile(
          'カレンダー形式',
          '月表示',
          () => _showCalendarFormatDialog(),
        ),
        _buildNavigationTile(
          'デフォルトKPI目標',
          'いいね数: 100, インプレッション: 2000',
          () => _showDefaultKPIDialog(),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSettingsSection(
      title: 'データ管理',
      icon: CupertinoIcons.folder,
      children: [
        _buildNavigationTile(
          'データエクスポート',
          'CSVまたはPDFで出力',
          () => _showExportDialog(),
        ),
        _buildNavigationTile(
          'データインポート',
          '既存データをインポート',
          () => _showImportDialog(),
        ),
        _buildNavigationTile(
          'データバックアップ',
          'クラウドに自動バックアップ',
          () => _showBackupDialog(),
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

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: 'サポート',
      icon: CupertinoIcons.question_circle,
      children: [
        _buildNavigationTile(
          'ヘルプ・使い方',
          'アプリの使用方法を確認',
          () => _showHelpDialog(),
        ),
        _buildNavigationTile(
          'フィードバック',
          'ご意見・ご要望をお聞かせください',
          () => _showFeedbackDialog(),
        ),
        _buildNavigationTile(
          'お問い合わせ',
          'サポートチームに連絡',
          () => _showContactDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsSection(
      title: 'アプリについて',
      icon: CupertinoIcons.info_circle,
      children: [
        _buildNavigationTile(
          'バージョン',
          '1.0.0',
          null,
        ),
        _buildNavigationTile(
          'プライバシーポリシー',
          '個人情報の取り扱いについて',
          () => _showPrivacyDialog(),
        ),
        _buildNavigationTile(
          '利用規約',
          'サービス利用規約',
          () => _showTermsDialog(),
        ),
        _buildNavigationTile(
          'ライセンス',
          'オープンソースライセンス',
          () => _showLicenseDialog(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
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
                  style: AppTypography.headline,
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
                  style: AppTypography.body,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
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
                        color: onTap != null ? AppColors.label : AppColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.secondaryLabel,
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