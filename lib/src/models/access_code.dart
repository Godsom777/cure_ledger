/// Hospital-issued access code for role-bound authentication
/// Format: [HOSPITALCODE]-[ROLE]-[RANDOM]
/// Example: LUTH-SW-8842
class AccessCode {
  final String id;
  final String code;
  final String hospitalId;
  final String role; // SW = Social Worker, FIN = Finance, etc.
  final DateTime expiresAt;
  final bool isUsed;
  final String? usedById;
  final DateTime? usedAt;
  final DateTime createdAt;
  final String createdById;

  const AccessCode({
    required this.id,
    required this.code,
    required this.hospitalId,
    required this.role,
    required this.expiresAt,
    required this.isUsed,
    this.usedById,
    this.usedAt,
    required this.createdAt,
    required this.createdById,
  });

  /// Check if code is still valid
  bool get isValid => !isUsed && DateTime.now().isBefore(expiresAt);

  /// Check if code is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AccessCode copyWith({
    String? id,
    String? code,
    String? hospitalId,
    String? role,
    DateTime? expiresAt,
    bool? isUsed,
    String? usedById,
    DateTime? usedAt,
    DateTime? createdAt,
    String? createdById,
  }) {
    return AccessCode(
      id: id ?? this.id,
      code: code ?? this.code,
      hospitalId: hospitalId ?? this.hospitalId,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      usedById: usedById ?? this.usedById,
      usedAt: usedAt ?? this.usedAt,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'hospitalId': hospitalId,
      'role': role,
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed,
      'usedById': usedById,
      'usedAt': usedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
    };
  }

  factory AccessCode.fromJson(Map<String, dynamic> json) {
    return AccessCode(
      id: json['id'] as String,
      code: json['code'] as String,
      hospitalId: json['hospitalId'] as String,
      role: json['role'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isUsed: json['isUsed'] as bool,
      usedById: json['usedById'] as String?,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdById: json['createdById'] as String,
    );
  }
}
