import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';
import '../../../data/mock/mock_posts.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<PostModel> _posts;
  List<PostModel> _rankedPosts = [];

  // ランキングの種類
  final List<String> _rankingTabs = [
    'いいね数',
    'インプレッション',
    '伸び率',
    'スコア',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _rankingTabs.length, vsync: this);
    _posts = MockPosts.generateMockPosts();
    _updateRanking(0); // 初期はいいね数ランキング
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _updateRanking(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateRanking(int tabIndex) {
    setState(() {
      final publishedPosts = _posts.where((post) => post.isPublished).toList();
      
      switch (tabIndex) {
        case 0: // いいね数
          _rankedPosts = publishedPosts
            ..sort((a, b) => b.performance.day30Likes.compareTo(a.performance.day30Likes));
          break;
        case 1: // インプレッション数
          _rankedPosts = publishedPosts
            ..sort((a, b) => b.performance.day30Impressions.compareTo(a.performance.day30Impressions));
          break;
        case 2: // 伸び率
          _rankedPosts = publishedPosts
            ..sort((a, b) => b.performance.likesGrowthRate1to7.compareTo(a.performance.likesGrowthRate1to7));
          break;
        case 3: // スコア
          _rankedPosts = publishedPosts
            ..sort((a, b) => b.performanceScore.compareTo(a.performanceScore));
          break;
      }
      
      // 上位20件のみ表示
      _rankedPosts = _rankedPosts.take(20).toList();
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
            _buildTabBar(),
            _buildSummaryCard(),
            Expanded(
              child: _buildRankingList(),
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
            AppColors.accent.withOpacity(0.1),
            AppColors.systemPink.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
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
                colors: [AppColors.accent, AppColors.systemPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.chart_bar_fill,
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
                  'ランキング',
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  'パフォーマンス順位',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _showFilterDialog,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              CupertinoIcons.slider_horizontal_3,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _rankingTabs
            .map((title) => Tab(
                  text: title,
                ))
            .toList(),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.systemGray,
        labelStyle: AppTypography.footnote.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.footnote,
        indicator: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_rankedPosts.isEmpty) return const SizedBox();

    final topPost = _rankedPosts.first;
    String summaryText = '';
    String summaryValue = '';

    switch (_tabController.index) {
      case 0:
        summaryText = '最高いいね数';
        summaryValue = '${topPost.performance.day30Likes}';
        break;
      case 1:
        summaryText = '最高インプレッション数';
        summaryValue = '${topPost.performance.day30Impressions}';
        break;
      case 2:
        summaryText = '最高伸び率';
        summaryValue = '${topPost.performance.likesGrowthRate1to7.toStringAsFixed(1)}%';
        break;
      case 3:
        summaryText = '最高スコア';
        summaryValue = '${topPost.performanceScore.toStringAsFixed(1)}%';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.systemGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.star_fill,
              color: AppColors.systemGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryText,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
                Text(
                  summaryValue,
                  style: AppTypography.title2.copyWith(
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_rankedPosts.length}件中',
            style: AppTypography.caption1.copyWith(
              color: AppColors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList() {
    if (_rankedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 64,
              color: AppColors.systemGray3,
            ),
            const SizedBox(height: 16),
            Text(
              'データがありません',
              style: AppTypography.headline.copyWith(
                color: AppColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '投稿のパフォーマンスデータを入力してください',
              style: AppTypography.footnote.copyWith(
                color: AppColors.tertiaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rankedPosts.length,
      itemBuilder: (context, index) {
        final post = _rankedPosts[index];
        return _buildRankingItem(post, index + 1);
      },
    );
  }

  Widget _buildRankingItem(PostModel post, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
        border: rank <= 3
            ? Border.all(
                color: _getRankColor(rank).withOpacity(0.3),
                width: 2,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildRankBadge(rank),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.content,
                    style: AppTypography.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildMetrics(post),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color rankColor = _getRankColor(rank);
    IconData rankIcon = CupertinoIcons.number;

    if (rank == 1) {
      rankIcon = CupertinoIcons.star_fill;
    } else if (rank == 2) rankIcon = CupertinoIcons.circle_fill;
    else if (rank == 3) rankIcon = CupertinoIcons.star;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: rank <= 3
          ? Icon(
              rankIcon,
              color: rankColor,
              size: 20,
            )
          : Center(
              child: Text(
                '$rank',
                style: AppTypography.headline.copyWith(
                  color: rankColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.systemGold;
      case 2:
        return AppColors.systemGray;
      case 3:
        return AppColors.systemBrown;
      default:
        return AppColors.systemGray2;
    }
  }

  Widget _buildMetrics(PostModel post) {
    String primaryValue = '';
    String secondaryValue = '';

    switch (_tabController.index) {
      case 0: // いいね数
        primaryValue = '${post.performance.day30Likes} いいね';
        secondaryValue = '${post.performance.day30Impressions} インプレッション';
        break;
      case 1: // インプレッション数
        primaryValue = '${post.performance.day30Impressions} インプレッション';
        secondaryValue = '${post.performance.day30Likes} いいね';
        break;
      case 2: // 伸び率
        primaryValue = '${post.performance.likesGrowthRate1to7.toStringAsFixed(1)}% 伸び率';
        secondaryValue = '${post.performance.day7Likes} → ${post.performance.day30Likes} いいね';
        break;
      case 3: // スコア
        primaryValue = '${post.performanceScore.toStringAsFixed(1)}% スコア';
        secondaryValue = '目標達成度';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primaryValue,
          style: AppTypography.headline.copyWith(
            color: AppColors.primary,
          ),
        ),
        if (secondaryValue.isNotEmpty)
          Text(
            secondaryValue,
            style: AppTypography.footnote.copyWith(
              color: AppColors.secondaryLabel,
            ),
          ),
      ],
    );
  }

  void _showFilterDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('フィルター'),
        content: const Text('フィルター機能は準備中です。'),
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