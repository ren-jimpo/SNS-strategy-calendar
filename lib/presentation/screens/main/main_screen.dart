import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../calendar/calendar_screen.dart';
import '../ranking/ranking_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../kpi/kpi_management_screen.dart';
import '../account/account_management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const AccountManagementScreen(),
    const KpiManagementScreen(),
    const RankingScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: CupertinoIcons.calendar,
      activeIcon: CupertinoIcons.calendar_badge_plus,
      label: 'カレンダー',
      subtitle: '投稿スケジュール管理',
      color: AppColors.primary,
      gradient: AppColors.engagementGradient,
    ),
    NavigationItem(
      icon: CupertinoIcons.person_2,
      activeIcon: CupertinoIcons.person_2_fill,
      label: 'アカウント管理',
      subtitle: 'SNSアカウント管理',
      color: AppColors.systemBlue,
      gradient: [AppColors.systemBlue, AppColors.systemIndigo],
    ),
    NavigationItem(
      icon: CupertinoIcons.chart_pie,
      activeIcon: CupertinoIcons.chart_pie_fill,
      label: 'KPI管理',
      subtitle: '長期戦略・目標管理',
      color: AppColors.accentPurple,
      gradient: [AppColors.accentPurple, AppColors.systemIndigo],
    ),
    NavigationItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'ランキング',
      subtitle: 'パフォーマンス順位',
      color: AppColors.accent,
      gradient: AppColors.socialGradient,
    ),
    NavigationItem(
      icon: CupertinoIcons.graph_circle,
      activeIcon: CupertinoIcons.graph_circle_fill,
      label: '分析',
      subtitle: 'データ分析レポート',
      color: AppColors.engagement,
      gradient: AppColors.performanceGradient,
    ),
    NavigationItem(
      icon: CupertinoIcons.settings,
      activeIcon: CupertinoIcons.settings_solid,
      label: '設定',
      subtitle: 'アプリ設定・管理',
      color: AppColors.systemGray,
      gradient: [AppColors.systemGray2, AppColors.systemGray4],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Row(
        children: [
          // デスクトップ用の固定サイドバー（幅768px以上で表示）
          if (MediaQuery.of(context).size.width >= 768)
            _buildSidebar(),
          // メインコンテンツ
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.secondarySystemGroupedBackground,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondarySystemGroupedBackground,
            AppColors.systemGroupedBackground,
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.systemGray.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return SafeArea(
      child: Column(
        children: [
          // ヘッダー
          _buildSidebarHeader(),
          // エンゲージメント統計
          _buildEngagementStats(),
          // ナビゲーションアイテム
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildNavigationTile(index);
              },
            ),
          ),
          // フッター
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ロゴアイコン - グラデーション効果
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.socialGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.calendar_today,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          // アプリ名
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: AppColors.socialGradient,
            ).createShader(bounds),
            child: Text(
              'SNS管理カレンダー',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '効率的な投稿管理',
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          // バージョン情報
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'v1.0.0',
              style: AppTypography.caption2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.engagement.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.engagement.withOpacity(0.2),
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
                color: AppColors.engagement,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '今月の統計',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.engagement,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('投稿数', '48', AppColors.primary),
              _buildStatItem('いいね', '1.2K', AppColors.likes),
              _buildStatItem('シェア', '342', AppColors.shares),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headline.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption2.copyWith(
            color: AppColors.tertiaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTile(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
            _animationController.reset();
            _animationController.forward();
            
            // モバイルの場合はドロワーを閉じる
            if (MediaQuery.of(context).size.width < 768) {
              Navigator.pop(context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(
                      colors: item.gradient.map((c) => c.withOpacity(0.15)).toList(),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: item.color.withOpacity(0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // アイコン
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(colors: item.gradient)
                          : null,
                      color: isSelected ? null : item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? Colors.white : item.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // テキスト
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: AppTypography.body.copyWith(
                            color: isSelected ? item.color : AppColors.label,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 選択インジケーター
                  if (isSelected) ...[
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: item.gradient),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(
            color: AppColors.separator.withOpacity(0.5),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // ユーザーアバター
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.socialGradient,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.person_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ユーザー名',
                      style: AppTypography.subhead.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.systemGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'オンライン',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.systemGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // メニューボタン
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.systemGray6,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconButton(
                  icon: const Icon(CupertinoIcons.ellipsis),
                  color: AppColors.systemGray,
                  iconSize: 18,
                  onPressed: () {
                    // ユーザーメニュー
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String subtitle;
  final Color color;
  final List<Color> gradient;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.gradient,
  });
} 