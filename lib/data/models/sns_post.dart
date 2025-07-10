class SnsPost {
  final String id;
  final String accountId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final DateTime scheduledDate;
  final PostStatus status;
  final String? postUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SnsPost({
    required this.id,
    required this.accountId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.tags,
    required this.scheduledDate,
    required this.status,
    this.postUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnsPost.fromJson(Map<String, dynamic> json) {
    return SnsPost(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.draft,
      ),
      postUrl: json['post_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // 新規作成時（UUIDではないID）の場合、IDを除外してSupabaseで自動生成
    final bool isNewRecord = !id.contains('-');
    
    final json = <String, dynamic>{
      'account_id': accountId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'tags': tags,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status.name,
      'post_url': postUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // 既存レコード（UUID形式のID）の場合のみIDを含める
    if (!isNewRecord) {
      json['id'] = id;
    }

    return json;
  }

  SnsPost copyWith({
    String? id,
    String? accountId,
    String? title,
    String? content,
    List<String>? imageUrls,
    List<String>? tags,
    DateTime? scheduledDate,
    PostStatus? status,
    String? postUrl,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SnsPost(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      postUrl: postUrl ?? this.postUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PostStatus {
  draft,
  scheduled,
  published,
  failed,
}

extension PostStatusExtension on PostStatus {
  String get displayName {
    switch (this) {
      case PostStatus.draft:
        return '下書き';
      case PostStatus.scheduled:
        return '予約投稿';
      case PostStatus.published:
        return '投稿済み';
      case PostStatus.failed:
        return '投稿失敗';
    }
  }
} 