class KpiModel {
  final String id;
  final String name;
  final String description;
  final KpiType type;
  final String unit;
  final double targetValue;
  final double currentValue;
  final String? phaseId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const KpiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.unit,
    required this.targetValue,
    required this.currentValue,
    this.phaseId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    return KpiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: KpiType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KpiType.kpi,
      ),
      unit: json['unit'] as String,
      targetValue: (json['target_value'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      phaseId: json['phase_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'unit': unit,
      'target_value': targetValue,
      'current_value': currentValue,
      'phase_id': phaseId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  KpiModel copyWith({
    String? id,
    String? name,
    String? description,
    KpiType? type,
    String? unit,
    double? targetValue,
    double? currentValue,
    String? phaseId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return KpiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      phaseId: phaseId ?? this.phaseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue * 100).clamp(0, 100) : 0;
  
  bool get isOnTrack => progress >= 80;
  bool get needsAttention => progress < 60;
}

class PhaseModel {
  final String id;
  final String name;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const PhaseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    return PhaseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  PhaseModel copyWith({
    String? id,
    String? name,
    String? description,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return PhaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum KpiType {
  kpi,
  kgi,
}

extension KpiTypeExtension on KpiType {
  String get displayName {
    switch (this) {
      case KpiType.kpi:
        return 'KPI';
      case KpiType.kgi:
        return 'KGI';
    }
  }
} 