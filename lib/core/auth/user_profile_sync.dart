import 'package:flutter/foundation.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/data/models/user_model.dart';

/// Reads `user` / `data.user` blocks from API JSON and persists profile fields.
class UserProfileSync {
  static Future<void> mergeFromApiResponse(
    SecureStorageService storage,
    Map<String, dynamic> response, {
    String? fallbackEmail,
  }) async {
    final userData = extractProfileMap(response);
    if (userData == null) return;

    if (userData['name'] == null) {
      final first = userData['first_name'] ?? userData['firstName'];
      final last = userData['last_name'] ?? userData['lastName'];
      if (first != null && first.toString().isNotEmpty) {
        userData['name'] = [first, last ?? '']
            .where((s) => s.toString().isNotEmpty)
            .join(' ');
      }
    }

    if ((userData['email'] == null || userData['email'].toString().isEmpty) &&
        fallbackEmail != null) {
      userData['email'] = fallbackEmail;
    }

    try {
      final existingUser = await storage.getUserModel();
      final newUserModel = UserModel.fromJson(userData);

      if (existingUser != null && _isEmptyShell(newUserModel)) {
        return;
      }

      if (existingUser != null) {
        final mergedUser = existingUser.copyWith(
          id: newUserModel.id != 0 ? newUserModel.id : null,
          name: newUserModel.name.isNotEmpty ? newUserModel.name : null,
          email: newUserModel.email.isNotEmpty ? newUserModel.email : null,
          phone: newUserModel.phone?.isNotEmpty == true ? newUserModel.phone : null,
          institute:
              newUserModel.institute?.isNotEmpty == true ? newUserModel.institute : null,
          instituteType: newUserModel.instituteType?.isNotEmpty == true
              ? newUserModel.instituteType
              : null,
          roleLevel: newUserModel.roleLevel != 0 ? newUserModel.roleLevel : null,
          role: newUserModel.role?.isNotEmpty == true ? newUserModel.role : null,
          roles: newUserModel.roles.isNotEmpty ? newUserModel.roles : null,
          avatar: newUserModel.avatar?.isNotEmpty == true ? newUserModel.avatar : null,
          passportNumber: newUserModel.passportNumber?.isNotEmpty == true
              ? newUserModel.passportNumber
              : null,
          studentClass: newUserModel.studentClass?.isNotEmpty == true
              ? newUserModel.studentClass
              : null,
          parentName:
              newUserModel.parentName?.isNotEmpty == true ? newUserModel.parentName : null,
          parentMobile: newUserModel.parentMobile?.isNotEmpty == true
              ? newUserModel.parentMobile
              : null,
          schoolId: newUserModel.schoolId,
        );
        await storage.saveUserModel(mergedUser);
      } else {
        await storage.saveUserModel(newUserModel);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to parse user profile: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Builds one normalized user map from nested API payloads (`/auth/me`, dashboard, login).
  static Map<String, dynamic>? extractProfileMap(Map<String, dynamic> response) {
    final merged = <String, dynamic>{};

    void absorb(dynamic node) {
      if (node is! Map) return;
      final map = node is Map<String, dynamic> ? node : Map<String, dynamic>.from(node);
      for (final entry in map.entries) {
        final value = entry.value;
        if (value == null) continue;
        if (value is Map || value is List) continue;
        final text = value.toString().trim();
        if (text.isEmpty) continue;
        merged.putIfAbsent(entry.key, () => value);
      }
    }

    absorb(response);
    absorb(response['user']);
    absorb(response['profile']);
    absorb(response['student']);
    absorb(response['admin']);

    final data = response['data'];
    if (data is Map) {
      absorb(data);
      absorb(data['user']);
      absorb(data['profile']);
      absorb(data['student']);
      absorb(data['admin']);
    }

    if (!_looksLikeUserMap(merged)) return null;

    return normalizeProfileFields(merged);
  }

  static Map<String, dynamic> normalizeProfileFields(Map<String, dynamic> map) {
    final out = Map<String, dynamic>.from(map);

    out['phone'] ??= _pickScalar(
      out,
      const ['phone', 'mobile', 'contact_number', 'contact_phone', 'phone_number', 'contact'],
    );

    out['institute'] ??= _pickScalar(
      out,
      const [
        'institute',
        'organization',
        'organisation',
        'trust_name',
        'school_name',
        'company',
        'branch_name',
        'center_name',
        'centre_name',
      ],
    );

    out['institute_type'] ??= _pickScalar(
      out,
      const [
        'institute_type',
        'institution_type',
        'school_type',
        'type',
        'category',
        'institute_category',
      ],
    );

    for (final nestedKey in ['school', 'organization', 'organisation', 'trust', 'institute']) {
      final nested = map[nestedKey];
      if (nested is! Map) continue;
      final nestedMap =
          nested is Map<String, dynamic> ? nested : Map<String, dynamic>.from(nested);

      out['institute'] ??= _pickScalar(
        nestedMap,
        const ['name', 'title', 'school_name', 'institute_name', 'organization_name'],
      );
      out['institute_type'] ??= _pickScalar(
        nestedMap,
        const ['institute_type', 'institution_type', 'school_type', 'type', 'category'],
      );
      out['phone'] ??= _pickScalar(
        nestedMap,
        const ['phone', 'mobile', 'contact_number', 'contact_phone'],
      );
    }

    return out;
  }

  static String? _pickScalar(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      if (value is Map) {
        final inner = value['name'] ?? value['title'] ?? value['label'];
        if (inner != null && inner.toString().trim().isNotEmpty) {
          return inner.toString().trim();
        }
      } else if (value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static bool _looksLikeUserMap(Map<String, dynamic> map) {
    return map.containsKey('email') ||
        map.containsKey('name') ||
        map.containsKey('id') ||
        map.containsKey('role_level') ||
        map.containsKey('roleLevel') ||
        map.containsKey('phone') ||
        map.containsKey('mobile');
  }

  static bool _isEmptyShell(UserModel model) {
    return model.id == 0 &&
        model.name.isEmpty &&
        model.email.isEmpty &&
        (model.phone == null || model.phone!.isEmpty);
  }
}
