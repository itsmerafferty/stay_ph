enum UserRole {
  tenant,
  landlord;

  String get displayName {
    switch (this) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.landlord:
        return 'Landlord';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'tenant':
        return UserRole.tenant;
      case 'landlord':
        return UserRole.landlord;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}

class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: UserRole.fromString(json['role'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
