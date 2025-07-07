import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final bool showPerformance;
  final bool compact;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showPerformance = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
        vertical: compact ? 4 : 8,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: _getPhaseGradient(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.getPhaseColor(post.phase.name).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getPhaseColor(post.phase.name).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  if (!compact) ...[
                    const SizedBox(height: 16),
                    _buildContent(),
                    const SizedBox(height: 16),
                    _buildMetadata(),
                    if (showPerformance) ...[
                      const SizedBox(height: 16),
                      _buildPerformanceSection(),
                    ],
                  ] else ...[
                    const SizedBox(height: 8),
                    _buildCompactContent(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getPhaseGradient() {
    switch (post.phase) {
      case PostPhase.planning:
        return LinearGradient(
          colors: [
            AppColors.secondarySystemGroupedBackground,
            AppColors.systemGray6.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PostPhase.development:
        return LinearGradient(
          colors: [
            AppColors.accentOrange.withOpacity(0.05),
            AppColors.systemOrange.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PostPhase.launch:
        return LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.systemBlue.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PostPhase.growth:
        return LinearGradient(
          colors: [
            AppColors.systemGreen.withOpacity(0.05),
            AppColors.systemMint.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PostPhase.maintenance:
        return LinearGradient(
          colors: [
            AppColors.systemPurple.withOpacity(0.05),
            AppColors.systemIndigo.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // フェーズアイコン
        Container(
          width: compact ? 36 : 44,
          height: compact ? 36 : 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getPhaseGradientColors(),
            ),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: AppColors.getPhaseColor(post.phase.name).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getPhaseIcon(),
            color: Colors.white,
            size: compact ? 18 : 22,
          ),
        ),
        const SizedBox(width: 12),
        // タイトル情報
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getPhaseText(),
                      style: (compact ? AppTypography.subhead : AppTypography.headline).copyWith(
                        color: AppColors.getPhaseColor(post.phase.name),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildTypeIcon(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('M月d日(E) HH:mm', 'ja').format(post.scheduledDate),
                style: (compact ? AppTypography.caption1 : AppTypography.body).copyWith(
                  color: AppColors.secondaryLabel,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // ステータス
        if (!compact) _buildStatusBadge(),
      ],
    );
  }

  List<Color> _getPhaseGradientColors() {
    switch (post.phase) {
      case PostPhase.planning:
        return [AppColors.systemGray, AppColors.systemGray2];
      case PostPhase.development:
        return [AppColors.accentOrange, AppColors.systemOrange];
      case PostPhase.launch:
        return [AppColors.primary, AppColors.systemBlue];
      case PostPhase.growth:
        return [AppColors.systemGreen, AppColors.systemMint];
      case PostPhase.maintenance:
        return [AppColors.systemPurple, AppColors.systemIndigo];
    }
  }

  IconData _getPhaseIcon() {
    switch (post.phase) {
      case PostPhase.planning:
        return CupertinoIcons.lightbulb;
      case PostPhase.development:
        return CupertinoIcons.hammer;
      case PostPhase.launch:
        return CupertinoIcons.rocket;
      case PostPhase.growth:
        return CupertinoIcons.chart_bar_fill;
      case PostPhase.maintenance:
        return CupertinoIcons.gear;
    }
  }

  String _getPhaseText() {
    switch (post.phase) {
      case PostPhase.planning:
        return '企画中';
      case PostPhase.development:
        return '制作中';
      case PostPhase.launch:
        return '配信済';
      case PostPhase.growth:
        return '分析中';
      case PostPhase.maintenance:
        return 'メンテナンス';
    }
  }

  Widget _buildTypeIcon() {
    Color typeColor = AppColors.systemBlue;
    IconData typeIcon = _getTypeIcon();

    return Container(
      width: compact ? 28 : 32,
      height: compact ? 28 : 32,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        typeIcon,
        color: typeColor,
        size: compact ? 14 : 16,
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (post.type) {
      case PostType.announcement:
        return CupertinoIcons.speaker_1;
      case PostType.feature:
        return CupertinoIcons.star;
      case PostType.tutorial:
        return CupertinoIcons.book;
      case PostType.community:
        return CupertinoIcons.group;
      case PostType.news:
        return CupertinoIcons.news;
      case PostType.other:
        return CupertinoIcons.circle;
    }
  }

  Widget _buildStatusBadge() {
    bool isScheduled = post.scheduledDate.isAfter(DateTime.now());
    bool isToday = DateFormat('yyyy-MM-dd').format(post.scheduledDate) == 
                   DateFormat('yyyy-MM-dd').format(DateTime.now());

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isToday) {
      badgeColor = AppColors.systemRed;
      badgeText = '今日';
      badgeIcon = CupertinoIcons.alarm;
    } else if (isScheduled) {
      badgeColor = AppColors.systemOrange;
      badgeText = '予定';
      badgeIcon = CupertinoIcons.clock;
    } else {
      badgeColor = AppColors.systemGreen;
      badgeText = '配信済';
      badgeIcon = CupertinoIcons.checkmark_circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            color: badgeColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: AppTypography.caption1.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiarySystemBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.separator.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.take(3).map((tag) => _buildHashtag(tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.content,
          style: AppTypography.caption1.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: post.tags.take(2).map((tag) => _buildHashtag(tag, compact: true)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildHashtag(String tag, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.socialGradient.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        '#$tag',
        style: (compact ? AppTypography.caption2 : AppTypography.caption1).copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.tag,
          color: AppColors.tertiaryLabel,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          post.type.displayName,
          style: AppTypography.caption1.copyWith(
            color: AppColors.tertiaryLabel,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (post.isPublished) ...[
          Icon(
            CupertinoIcons.eye,
            color: AppColors.systemBlue,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.performance.day30Impressions}',
            style: AppTypography.caption1.copyWith(
              color: AppColors.systemBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPerformanceSection() {
    if (!post.isPublished) {
      return _buildTargetKPIs();
    }
    return _buildActualPerformance();
  }

  Widget _buildTargetKPIs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.engagement.withOpacity(0.05),
            AppColors.primary.withOpacity(0.03),
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
                CupertinoIcons.scope,
                color: AppColors.engagement,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '目標KPI',
                style: AppTypography.subhead.copyWith(
                  color: AppColors.engagement,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildKPIItem(
                icon: CupertinoIcons.heart,
                label: 'いいね',
                value: '${post.kpi.targetLikes}',
                color: AppColors.likes,
              ),
              const SizedBox(width: 24),
              _buildKPIItem(
                icon: CupertinoIcons.eye,
                label: 'インプレッション',
                value: '${post.kpi.targetImpressions}',
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActualPerformance() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.performanceGradient.map((c) => c.withOpacity(0.05)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.systemGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar_fill,
                color: AppColors.systemGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'パフォーマンス実績',
                style: AppTypography.subhead.copyWith(
                  color: AppColors.systemGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(post.performanceScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${post.performanceScore.toStringAsFixed(0)}%',
                  style: AppTypography.caption1.copyWith(
                    color: _getScoreColor(post.performanceScore),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceItem(
                  icon: CupertinoIcons.heart_fill,
                  label: 'いいね',
                  value: '${post.performance.day30Likes}',
                  color: AppColors.likes,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceItem(
                  icon: CupertinoIcons.eye_fill,
                  label: 'インプレッション',
                  value: '${post.performance.day30Impressions}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceItem(
                  icon: CupertinoIcons.arrow_up_circle_fill,
                  label: '伸び率',
                  value: '${post.performance.likesGrowthRate1to7.toStringAsFixed(1)}%',
                  color: AppColors.systemGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
      ],
    );
  }

  Widget _buildPerformanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
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
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.systemGreen;
    if (score >= 60) return AppColors.systemOrange;
    return AppColors.systemRed;
  }
} 