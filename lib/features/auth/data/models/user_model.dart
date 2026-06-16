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
    super.studentClass,
    super.parentName,
    super.parentMobile,
    super.instituteType,
    super.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: ApiJsonParser.asInt(json['id']),
      name: ApiJsonParser.asString(json['name']),
      email: ApiJsonParser.asString(json['email']),
      emailVerifiedAt: ApiJsonParser.tryString(json['email_verified_at']),
      phone: ApiJsonParser.tryString(json['phone']),
      passportNumber: ApiJsonParser.tryString(json['passport_number']),
      passportExpiry: ApiJsonParser.tryString(json['passport_expiry']),
      roleLevel: ApiJsonParser.asInt(json['role_level']),
      isAlumni: ApiJsonParser.asBool(json['is_alumni']),
      avatar: ApiJsonParser.tryString(json['avatar']),
      isActive: ApiJsonParser.asBool(json['is_active']),
      createdAt: ApiJsonParser.tryString(json['created_at']),
      updatedAt: ApiJsonParser.tryString(json['updated_at']),
      deletedAt: ApiJsonParser.tryString(json['deleted_at']),
      schoolId: json['school_id'] != null ? ApiJsonParser.asInt(json['school_id']) : null,
      institute: ApiJsonParser.tryString(json['institute']),
      role: ApiJsonParser.tryString(json['role']),
      studentClass: ApiJsonParser.tryString(json['class']) ?? ApiJsonParser.tryString(json['class_name']) ?? ApiJsonParser.tryString(json['student_class']),
      parentName: ApiJsonParser.tryString(json['parent_name']),
      parentMobile: ApiJsonParser.tryString(json['parent_mobile']) ?? ApiJsonParser.tryString(json['parent_phone']),
      instituteType: ApiJsonParser.tryString(json['institute_type']) ?? 
                     ApiJsonParser.tryString(json['institution_type']) ?? 
                     ApiJsonParser.tryString(json['school_type']) ??
                     (json['school'] is Map ? (ApiJsonParser.tryString(json['school']['institute_type']) ?? ApiJsonParser.tryString(json['school']['institution_type']) ?? ApiJsonParser.tryString(json['school']['type'])) : null),
      roles: () {
        final rolesData = json['roles'];
        if (rolesData is List) {
          return rolesData.map((e) {
            if (e is Map<String, dynamic>) {
              return UserRoleModel.fromJson(e);
            } else if (e is String) {
              return UserRoleModel(id: 0, name: e);
            }
            return const UserRoleModel(id: 0, name: 'Unknown');
          }).toList();
        }
        return const <UserRoleModel>[];
      }(),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? phone,
    String? passportNumber,
    String? passportExpiry,
    int? roleLevel,
    bool? isAlumni,
    String? avatar,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    int? schoolId,
    String? institute,
    String? role,
    String? studentClass,
    String? parentName,
    String? parentMobile,
    String? instituteType,
    List<UserRole>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phone: phone ?? this.phone,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      roleLevel: roleLevel ?? this.roleLevel,
      isAlumni: isAlumni ?? this.isAlumni,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      institute: institute ?? this.institute,
      role: role ?? this.role,
      studentClass: studentClass ?? this.studentClass,
      parentName: parentName ?? this.parentName,
      parentMobile: parentMobile ?? this.parentMobile,
      instituteType: instituteType ?? this.instituteType,
      roles: roles ?? this.roles,
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
      'class': studentClass,
      'parent_name': parentName,
      'parent_mobile': parentMobile,
      'institute_type': instituteType,
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
      guardName: ApiJsonParser.tryString(json['guard_name']),
      createdAt: ApiJsonParser.tryString(json['created_at']),
      updatedAt: ApiJsonParser.tryString(json['updated_at']),
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
