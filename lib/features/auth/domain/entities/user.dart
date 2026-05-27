class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.phone,
    this.passportNumber,
    this.passportExpiry,
    required this.roleLevel,
    required this.isAlumni,
    this.avatar,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.schoolId,
    this.institute,
    this.role,
    this.roles = const [],
  });

  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? phone;
  final String? passportNumber;
  final String? passportExpiry;
  final int roleLevel;
  final bool isAlumni;
  final String? avatar;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final int? schoolId;
  final String? institute;
  final String? role;
  final List<UserRole> roles;
}

class UserRole {
  const UserRole({
    required this.id,
    required this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? guardName;
  final String? createdAt;
  final String? updatedAt;
}
