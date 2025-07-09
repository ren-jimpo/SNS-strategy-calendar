import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/sns_account_model.dart';
import '../../data/models/post_model.dart';

class AccountTabBar extends StatefulWidget {
  final List<SNSAccount> accounts;
  final SNSAccount? selectedAccount;
  final Function(SNSAccount?) onAccountChanged;
  final VoidCallback onAddAccount;
  final bool showStats;
  final List<PostModel> filteredPosts;

  const AccountTabBar({
    super.key,
    required this.accounts,
    this.selectedAccount,
    required this.onAccountChanged,
    required this.onAddAccount,
    this.showStats = false,
    this.filteredPosts = const [],
  });

  @override
  State<AccountTabBar> createState() => _AccountTabBarState();
}

class _AccountTabBarState extends State<AccountTabBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showStats) _buildStatsHeader(),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(
                color: AppColors.separator.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // 全アカウント表示タブ
              _buildAccountTab(
                label: '全て',
                icon: CupertinoIcons.rectangle_grid_2x2,
                isSelected: widget.selectedAccount == null,
                onTap: () => widget.onAccountChanged(null),
                color: AppColors.systemGray,
              ),
              const SizedBox(width: 12),
              
              // 各アカウントタブ
              ...widget.accounts.map((account) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildAccountTab(
                      label: account.username,
                      icon: account.platformIcon,
                      isSelected: widget.selectedAccount?.id == account.id,
                      onTap: () => widget.onAccountChanged(account),
                      color: account.platformColor,
                      platformName: account.platform.displayName,
                    ),
                  )),
              
              // アカウント追加ボタン
              _buildAddAccountButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final totalPosts = widget.filteredPosts.length;
    final publishedPosts = widget.filteredPosts.where((post) => post.isPublished).length;
    final pendingPosts = totalPosts - publishedPosts;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.engagement],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.calendar,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'アカウント管理',
              style: AppTypography.title3.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildAccountStats(publishedPosts, pendingPosts),
        ],
      ),
    );
  }

  Widget _buildAccountStats(int publishedPosts, int pendingPosts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAccountStatChip('投稿済み', publishedPosts, AppColors.systemGreen),
          const SizedBox(width: 4),
          _buildAccountStatChip('予定', pendingPosts, AppColors.systemOrange),
        ],
      ),
    );
  }

  Widget _buildAccountStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: AppTypography.caption2.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    String? platformName,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: color, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 11,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption1.copyWith(
                      color: isSelected 
                          ? color
                          : Theme.of(context).brightness == Brightness.dark
                              ? AppColors.labelDark
                              : AppColors.label,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (platformName != null)
                    Text(
                      platformName,
                      style: AppTypography.caption2.copyWith(
                        color: isSelected 
                            ? color.withOpacity(0.8)
                            : AppColors.tertiaryLabel,
                        fontSize: 8,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: widget.onAddAccount,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                CupertinoIcons.plus,
                color: Colors.white,
                size: 11,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'アカウント追加',
              style: AppTypography.caption1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 