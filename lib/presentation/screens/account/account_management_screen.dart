import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/sns_account_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/mock/mock_posts.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  List<SNSAccount> _accounts = [];
  SNSAccount? _selectedAccount;
  late List<PostModel> _posts;
  List<PostModel> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _applyFilters();
  }

  void _initializeData() {
    // モックアカウントを生成
    AccountManager.generateMockAccounts();
    _accounts = AccountManager.activeAccounts;
    _selectedAccount = AccountManager.selectedAccount;
    
    // モック投稿を生成
    _posts = MockPosts.generateMockPosts();
  }

  void _applyFilters() {
    setState(() {
      _filteredPosts = _posts.where((post) {
        // アカウントフィルターをチェック
        if (_selectedAccount != null) {
          return post.accountId == _selectedAccount!.id;
        }
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildAccountManagementContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.systemBlue.withOpacity(0.1),
            AppColors.systemIndigo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.systemBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.separator.withOpacity(0.1),
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
                colors: [AppColors.systemBlue, AppColors.systemIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.systemBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.person_2_fill,
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
                  'アカウント管理',
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.systemBlue,
                  ),
                ),
                Text(
                  'SNSアカウントの管理と統計',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickAddButton(),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemBlue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.systemBlue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _showAddAccountModal,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              CupertinoIcons.plus,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountManagementContent() {
    if (_accounts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAccountOverview(),
        const SizedBox(height: 24),
        _buildAccountsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.systemBlue.withOpacity(0.1),
                  AppColors.systemIndigo.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.person_add,
              size: 48,
              color: AppColors.systemBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'アカウントがありません',
            style: AppTypography.title2.copyWith(
              color: AppColors.label,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SNSアカウントを追加して\n投稿管理を始めましょう',
            style: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildAddAccountButtonLarge(),
        ],
      ),
    );
  }

  Widget _buildAccountOverview() {
    final totalPosts = _filteredPosts.length;
    final publishedPosts = _filteredPosts.where((post) => post.isPublished).length;
    final pendingPosts = totalPosts - publishedPosts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.engagement.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_pie_fill,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'アカウント統計',
                style: AppTypography.title3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '総アカウント数',
                  '${_accounts.length}',
                  AppColors.systemBlue,
                  CupertinoIcons.person_2_fill,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewItem(
                  '総投稿数',
                  '$totalPosts',
                  AppColors.engagement,
                  CupertinoIcons.doc_text_fill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '投稿済み',
                  '$publishedPosts',
                  AppColors.systemGreen,
                  CupertinoIcons.checkmark_circle_fill,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewItem(
                  '予定投稿',
                  '$pendingPosts',
                  AppColors.systemOrange,
                  CupertinoIcons.clock_fill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.title2.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'アカウント一覧',
              style: AppTypography.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showAddAccountModal,
              icon: const Icon(CupertinoIcons.plus, size: 16),
              label: const Text('追加'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.systemBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...(_accounts.map((account) => _buildAccountCard(account))),
      ],
    );
  }

  Widget _buildAccountCard(SNSAccount account) {
    final accountPosts = _posts.where((post) => post.accountId == account.id).toList();
    final publishedCount = accountPosts.where((post) => post.isPublished).length;
    final pendingCount = accountPosts.length - publishedCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedAccount?.id == account.id 
              ? account.platformColor.withOpacity(0.5)
              : AppColors.separator.withOpacity(0.3),
          width: _selectedAccount?.id == account.id ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.separator.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: account.platformColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: account.platformColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  account.platformIcon,
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
                      account.displayName,
                      style: AppTypography.title3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.username,
                      style: AppTypography.body.copyWith(
                        color: AppColors.secondaryLabel,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: account.platformColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        account.platform.displayName,
                        style: AppTypography.caption1.copyWith(
                          color: account.platformColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  CupertinoIcons.ellipsis_circle,
                  color: AppColors.secondaryLabel,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'select':
                      _onAccountChanged(account);
                      break;
                    case 'edit':
                      _editAccount(account);
                      break;
                    case 'delete':
                      _deleteAccount(account);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'select',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.checkmark_circle, size: 16),
                        const SizedBox(width: 8),
                        Text('選択'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.pencil, size: 16),
                        const SizedBox(width: 8),
                        Text('編集'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.trash, size: 16, color: AppColors.systemRed),
                        const SizedBox(width: 8),
                        Text('削除', style: TextStyle(color: AppColors.systemRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAccountStatItem(
                  '投稿済み',
                  publishedCount,
                  AppColors.systemGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountStatItem(
                  '予定',
                  pendingCount,
                  AppColors.systemOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAccountStatItem(
                  '合計',
                  accountPosts.length,
                  AppColors.systemBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTypography.title3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButtonLarge() {
    return Container(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showAddAccountModal,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.systemBlue, AppColors.systemIndigo],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.systemBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.plus,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SNSアカウントを追加',
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onAccountChanged(SNSAccount? account) {
    setState(() {
      _selectedAccount = account;
      AccountManager.selectAccount(account?.id);
    });
    _applyFilters();
  }

  void _showAddAccountModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('アカウントを追加'),
        message: const Text('どのSNSプラットフォームのアカウントを追加しますか？'),
        actions: SNSPlatform.values.map((platform) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _addMockAccount(platform);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getPlatformIcon(platform),
                  color: _getPlatformColor(platform),
                ),
                const SizedBox(width: 8),
                Text(platform.displayName),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
    );
  }

  void _addMockAccount(SNSPlatform platform) {
    final newAccount = SNSAccount(
      id: '${platform.key}_${DateTime.now().millisecondsSinceEpoch}',
      platform: platform,
      username: '@new_${platform.key}_account',
      displayName: '新しい${platform.displayName}アカウント',
      connectedAt: DateTime.now(),
    );
    
    setState(() {
      AccountManager.addAccount(newAccount);
      _accounts = AccountManager.activeAccounts;
    });
    
    // 追加されたアカウントを選択
    _onAccountChanged(newAccount);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${platform.displayName}アカウントを追加しました'),
        backgroundColor: AppColors.systemGreen,
      ),
    );
  }

  void _editAccount(SNSAccount account) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('アカウント編集'),
        content: const Text('アカウント編集機能は今後実装予定です。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(SNSAccount account) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('アカウントを削除'),
        content: Text('${account.displayName}を削除しますか？この操作は取り消せません。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('削除'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                AccountManager.removeAccount(account.id);
                _accounts = AccountManager.activeAccounts;
                if (_selectedAccount?.id == account.id) {
                  _selectedAccount = null;
                  AccountManager.selectAccount(null);
                }
              });
              _applyFilters();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${account.displayName}を削除しました'),
                  backgroundColor: AppColors.systemRed,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(SNSPlatform platform) {
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

  Color _getPlatformColor(SNSPlatform platform) {
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
} 