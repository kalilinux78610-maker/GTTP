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
    this.studentClass,
    this.parentName,
    this.parentMobile,
    this.instituteType,
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
  final String? studentClass;
  final String? parentName;
  final String? parentMobile;
  final String? instituteType;
  final List<UserRole> roles;

  String get effectiveRole {
    if (role != null && role!.trim().isNotEmpty) return role!;
    if (roles.isNotEmpty && roles.first.name.trim().isNotEmpty) {
      return roles.first.name;
    }
    return roleLevel.toString();
  }
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
