import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/post_model.dart';
import '../../../data/mock/mock_posts.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late List<PostModel> _posts;
  int _selectedPeriod = 0; // 0: 7日, 1: 30日, 2: 90日

  final List<String> _periods = ['7日間', '30日間', '90日間'];

  @override
  void initState() {
    super.initState();
    _posts = MockPosts.generateMockPosts();
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildPerformanceChart(),
                  const SizedBox(height: 20),
                  _buildPhaseAnalysis(),
                  const SizedBox(height: 20),
                  _buildTagAnalysis(),
                  const SizedBox(height: 20),
                ],
              ),
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
            AppColors.engagement.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.engagement.withOpacity(0.2),
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
                colors: [AppColors.engagement, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.engagement.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.graph_circle_fill,
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
                  '分析',
                  style: AppTypography.title1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.engagement,
                  ),
                ),
                Text(
                  'データ分析レポート',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.engagement,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.engagement.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _showExportDialog,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              CupertinoIcons.share,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = _selectedPeriod == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: AppTypography.footnote.copyWith(
                    color: isSelected ? Colors.white : AppColors.label,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final publishedPosts = _posts.where((p) => p.isPublished).toList();
    final totalLikes = publishedPosts.fold<int>(
      0,
      (sum, post) => sum + post.performance.day30Likes,
    );
    final totalImpressions = publishedPosts.fold<int>(
      0,
      (sum, post) => sum + post.performance.day30Impressions,
    );
    final avgScore = publishedPosts.isNotEmpty
        ? publishedPosts.fold<double>(
              0,
              (sum, post) => sum + post.performanceScore,
            ) /
            publishedPosts.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            '総いいね数',
            totalLikes.toString(),
            CupertinoIcons.heart_fill,
            AppColors.systemRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            '総インプレッション',
            totalImpressions.toString(),
            CupertinoIcons.eye_fill,
            AppColors.systemBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            '平均スコア',
            '${avgScore.toStringAsFixed(1)}%',
            CupertinoIcons.chart_bar_fill,
            AppColors.systemGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.caption1.copyWith(
              color: AppColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headline.copyWith(
              color: AppColors.label,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.graph_square,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'パフォーマンス推移',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData() {
    final publishedPosts = _posts
        .where((p) => p.isPublished)
        .toList()
      ..sort((a, b) => a.publishedDate!.compareTo(b.publishedDate!));

    final spots = <FlSpot>[];
    for (int i = 0; i < publishedPosts.length && i < 10; i++) {
      spots.add(FlSpot(
        i.toDouble(),
        publishedPosts[i].performance.day30Likes.toDouble(),
      ));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.systemGray5,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                '${value.toInt() + 1}',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toInt().toString(),
                style: AppTypography.caption2.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_pie,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'フェーズ別分析',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPhaseStats(),
        ],
      ),
    );
  }

  Widget _buildPhaseStats() {
    final phaseStats = <PostPhase, int>{};
    final publishedPosts = _posts.where((p) => p.isPublished);

    for (final phase in PostPhase.values) {
      phaseStats[phase] = publishedPosts.where((p) => p.phase == phase).length;
    }

    return Column(
      children: PostPhase.values.map((phase) {
        final count = phaseStats[phase] ?? 0;
        final total = publishedPosts.length;
        final percentage = total > 0 ? (count / total) * 100 : 0.0;

        Color phaseColor = AppColors.systemGray;
        switch (phase) {
          case PostPhase.planning:
            phaseColor = AppColors.systemGray;
            break;
          case PostPhase.development:
            phaseColor = AppColors.systemOrange;
            break;
          case PostPhase.launch:
            phaseColor = AppColors.systemBlue;
            break;
          case PostPhase.growth:
            phaseColor = AppColors.systemGreen;
            break;
          case PostPhase.maintenance:
            phaseColor = AppColors.systemPurple;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: phaseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  phase.displayName,
                  style: AppTypography.body,
                ),
              ),
              Text(
                '$count件 (${percentage.toStringAsFixed(1)}%)',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.tag,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'タグ別パフォーマンス',
                style: AppTypography.headline,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTagStats(),
        ],
      ),
    );
  }

  Widget _buildTagStats() {
    final tagStats = <String, Map<String, dynamic>>{};
    final publishedPosts = _posts.where((p) => p.isPublished);

    for (final post in publishedPosts) {
      for (final tag in post.tags) {
        if (!tagStats.containsKey(tag)) {
          tagStats[tag] = {
            'count': 0,
            'totalLikes': 0,
            'totalImpressions': 0,
          };
        }
        tagStats[tag]!['count']++;
        tagStats[tag]!['totalLikes'] += post.performance.day30Likes;
        tagStats[tag]!['totalImpressions'] += post.performance.day30Impressions;
      }
    }

    final sortedTags = tagStats.entries.toList()
      ..sort((a, b) => b.value['totalLikes'].compareTo(a.value['totalLikes']));

    return Column(
      children: sortedTags.take(5).map((entry) {
        final tag = entry.key;
        final stats = entry.value;
        final avgLikes = stats['count'] > 0 ? stats['totalLikes'] / stats['count'] : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$tag',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '平均 ${avgLikes.toStringAsFixed(1)} いいね',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ),
              Text(
                '${stats['count']}件',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.tertiaryLabel,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showExportDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('レポート出力'),
        content: const Text('レポート出力機能は準備中です。'),
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