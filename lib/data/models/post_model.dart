import 'package:flutter/material.dart';

/// 投稿フェーズ
enum PostPhase {
  planning('企画'),
  development('開発'),
  launch('ローンチ'),
  growth('成長'),
  maintenance('メンテナンス');

  const PostPhase(this.displayName);
  final String displayName;
}

/// 投稿タイプ
enum PostType {
  announcement('お知らせ'),
  feature('機能紹介'),
  tutorial('チュートリアル'),
  community('コミュニティ'),
  news('ニュース'),
  other('その他');

  const PostType(this.displayName);
  final String displayName;
}

/// 投稿実績データ
class PostPerformance {
  final int day1Likes;
  final int day1Impressions;
  final int day7Likes;
  final int day7Impressions;
  final int day30Likes;
  final int day30Impressions;
  final DateTime? day1UpdatedAt;
  final DateTime? day7UpdatedAt;
  final DateTime? day30UpdatedAt;

  const PostPerformance({
    this.day1Likes = 0,
    this.day1Impressions = 0,
    this.day7Likes = 0,
    this.day7Impressions = 0,
    this.day30Likes = 0,
    this.day30Impressions = 0,
    this.day1UpdatedAt,
    this.day7UpdatedAt,
    this.day30UpdatedAt,
  });

  /// いいね数の伸び率（1日→7日）
  double get likesGrowthRate1to7 {
    if (day1Likes == 0) return 0;
    return ((day7Likes - day1Likes) / day1Likes) * 100;
  }

  /// いいね数の伸び率（7日→30日）
  double get likesGrowthRate7to30 {
    if (day7Likes == 0) return 0;
    return ((day30Likes - day7Likes) / day7Likes) * 100;
  }

  /// インプレッション数の伸び率（1日→7日）
  double get impressionsGrowthRate1to7 {
    if (day1Impressions == 0) return 0;
    return ((day7Impressions - day1Impressions) / day1Impressions) * 100;
  }

  /// インプレッション数の伸び率（7日→30日）
  double get impressionsGrowthRate7to30 {
    if (day7Impressions == 0) return 0;
    return ((day30Impressions - day7Impressions) / day7Impressions) * 100;
  }

  PostPerformance copyWith({
    int? day1Likes,
    int? day1Impressions,
    int? day7Likes,
    int? day7Impressions,
    int? day30Likes,
    int? day30Impressions,
    DateTime? day1UpdatedAt,
    DateTime? day7UpdatedAt,
    DateTime? day30UpdatedAt,
  }) {
    return PostPerformance(
      day1Likes: day1Likes ?? this.day1Likes,
      day1Impressions: day1Impressions ?? this.day1Impressions,
      day7Likes: day7Likes ?? this.day7Likes,
      day7Impressions: day7Impressions ?? this.day7Impressions,
      day30Likes: day30Likes ?? this.day30Likes,
      day30Impressions: day30Impressions ?? this.day30Impressions,
      day1UpdatedAt: day1UpdatedAt ?? this.day1UpdatedAt,
      day7UpdatedAt: day7UpdatedAt ?? this.day7UpdatedAt,
      day30UpdatedAt: day30UpdatedAt ?? this.day30UpdatedAt,
    );
  }
}

/// KPI目標値
class PostKPI {
  final int targetLikes;
  final int targetImpressions;
  final String description;

  const PostKPI({
    required this.targetLikes,
    required this.targetImpressions,
    this.description = '',
  });

  PostKPI copyWith({
    int? targetLikes,
    int? targetImpressions,
    String? description,
  }) {
    return PostKPI(
      targetLikes: targetLikes ?? this.targetLikes,
      targetImpressions: targetImpressions ?? this.targetImpressions,
      description: description ?? this.description,
    );
  }
}

/// 投稿データモデル
class PostModel {
  final String id;
  final String content;
  final DateTime scheduledDate;
  final DateTime? publishedDate;
  final PostPhase phase;
  final PostType type;
  final List<String> tags;
  final PostKPI kpi;
  final PostPerformance performance;
  final String memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;

  const PostModel({
    required this.id,
    required this.content,
    required this.scheduledDate,
    this.publishedDate,
    required this.phase,
    required this.type,
    this.tags = const [],
    required this.kpi,
    this.performance = const PostPerformance(),
    this.memo = '',
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
  });

  /// 投稿後の経過日数
  int? get daysSincePublished {
    if (publishedDate == null) return null;
    return DateTime.now().difference(publishedDate!).inDays;
  }

  /// データ入力が必要かどうか
  bool get needsDataEntry {
    if (!isPublished || publishedDate == null) return false;
    
    final days = daysSincePublished!;
    
    // 1日後のデータが未入力
    if (days >= 1 && performance.day1UpdatedAt == null) return true;
    
    // 7日後のデータが未入力
    if (days >= 7 && performance.day7UpdatedAt == null) return true;
    
    // 30日後のデータが未入力
    if (days >= 30 && performance.day30UpdatedAt == null) return true;
    
    return false;
  }

  /// パフォーマンススコア（総合評価）
  double get performanceScore {
    if (!isPublished) return 0.0;
    
    final likesScore = performance.day30Likes / kpi.targetLikes.clamp(1, double.infinity);
    final impressionsScore = performance.day30Impressions / kpi.targetImpressions.clamp(1, double.infinity);
    
    return ((likesScore + impressionsScore) / 2 * 100).clamp(0, 100);
  }

  PostModel copyWith({
    String? id,
    String? content,
    DateTime? scheduledDate,
    DateTime? publishedDate,
    PostPhase? phase,
    PostType? type,
    List<String>? tags,
    PostKPI? kpi,
    PostPerformance? performance,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      publishedDate: publishedDate ?? this.publishedDate,
      phase: phase ?? this.phase,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      kpi: kpi ?? this.kpi,
      performance: performance ?? this.performance,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
} 