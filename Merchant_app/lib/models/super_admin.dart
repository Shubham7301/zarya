class SuperAdmin {
  final String id;
  final String name;
  final String email;
  final String role; // 'super_admin', 'admin', 'viewer'
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  SuperAdmin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory SuperAdmin.fromMap(Map<String, dynamic> map, {String? id}) {
    return SuperAdmin(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'viewer',
      permissions: List<String>.from(map['permissions'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] is String 
              ? DateTime.parse(map['lastLoginAt'])
              : DateTime.now())
          : null,
    );
  }

  factory SuperAdmin.fromJson(Map<String, dynamic> json) {
    return SuperAdmin.fromMap(json, id: json['id']);
  }

  SuperAdmin copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return SuperAdmin(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Check if admin has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'super_admin';
  }

  // Check if admin can manage merchants
  bool canManageMerchants() {
    return hasPermission('manage_merchants');
  }

  // Check if admin can view analytics
  bool canViewAnalytics() {
    return hasPermission('view_analytics');
  }

  // Check if admin can manage other admins
  bool canManageAdmins() {
    return hasPermission('manage_admins');
  }
}
