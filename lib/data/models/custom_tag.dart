class CustomTag {
  final String id;
  final String tag;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const CustomTag({
    required this.id,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory CustomTag.fromJson(Map<String, dynamic> json) {
    return CustomTag(
      id: json['id'] as String,
      tag: json['tag'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    // 新規作成時（UUIDではないID）の場合、IDを除外してSupabaseで自動生成
    final bool isNewRecord = !id.contains('-');
    
    final json = <String, dynamic>{
      'tag': tag,
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

  CustomTag copyWith({
    String? id,
    String? tag,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CustomTag(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTag &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomTag{id: $id, tag: $tag, isActive: $isActive}';
  }
} 