class SnsAccount {
  final String id;
  final String accountName;
  final String platform;
  final String? profileImageUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SnsAccount({
    required this.id,
    required this.accountName,
    required this.platform,
    this.profileImageUrl,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnsAccount.fromJson(Map<String, dynamic> json) {
    return SnsAccount(
      id: json['id'] as String,
      accountName: json['account_name'] as String,
      platform: json['platform'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // 新規作成時（UUIDではないID）の場合、IDを除外してSupabaseで自動生成
    final bool isNewRecord = !id.contains('-');
    
    final json = <String, dynamic>{
      'account_name': accountName,
      'platform': platform,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // 既存レコード（UUID形式のID）の場合のみIDを含める
    if (!isNewRecord) {
      json['id'] = id;
    }

    return json;
  }

  SnsAccount copyWith({
    String? id,
    String? accountName,
    String? platform,
    String? profileImageUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SnsAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      platform: platform ?? this.platform,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 