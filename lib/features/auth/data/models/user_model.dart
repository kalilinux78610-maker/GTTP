import 'package:gttp/core/network/api_json_parser.dart';
import 'package:gttp/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.emailVerifiedAt,
    super.phone,
    super.passportNumber,
    super.passportExpiry,
    required super.roleLevel,
    required super.isAlumni,
    super.avatar,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    super.schoolId,
    super.institute,
    super.role,
    super.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: ApiJsonParser.asInt(json['id']),
      name: ApiJsonParser.asString(json['name']),
      email: ApiJsonParser.asString(json['email']),
      emailVerifiedAt: json['email_verified_at'] as String?,
      phone: json['phone'] as String?,
      passportNumber: json['passport_number'] as String?,
      passportExpiry: json['passport_expiry'] as String?,
      roleLevel: ApiJsonParser.asInt(json['role_level']),
      isAlumni: ApiJsonParser.asBool(json['is_alumni']),
      avatar: json['avatar'] as String?,
      isActive: ApiJsonParser.asBool(json['is_active']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      schoolId: json['school_id'] != null ? ApiJsonParser.asInt(json['school_id']) : null,
      institute: json['institute'] as String?,
      role: json['role'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRoleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone': phone,
      'passport_number': passportNumber,
      'passport_expiry': passportExpiry,
      'role_level': roleLevel,
      'is_alumni': isAlumni,
      'avatar': avatar,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'school_id': schoolId,
      'institute': institute,
      'role': role,
      'roles': roles.map((e) => (e as UserRoleModel).toJson()).toList(),
    };
  }
}

class UserRoleModel extends UserRole {
  const UserRoleModel({
    required super.id,
    required super.name,
    super.guardName,
    super.createdAt,
    super.updatedAt,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: ApiJsonParser.asInt(json['id']),
      name: ApiJsonParser.asString(json['name']),
      guardName: json['guard_name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
