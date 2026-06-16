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
    dynamic userData = response['user'];
    if (userData == null && response['data'] != null && response['data'] is Map) {
      userData = response['data']['user'] ?? 
                 response['data']['student'] ?? 
                 response['data']['admin'];
    }
    userData ??= response['student'];
    userData ??= response['admin'];
    userData ??= response['user_data'];
    userData ??= response;

    if (userData != null && userData is Map<String, dynamic>) {
      // If name is missing but we have first/last, construct it before parsing
      if (userData['name'] == null) {
        final first = userData['first_name'] ?? userData['firstName'];
        final last = userData['last_name'] ?? userData['lastName'];
        if (first != null && first.toString().isNotEmpty) {
          userData['name'] = [first, last ?? ''].where((s) => s.toString().isNotEmpty).join(' ');
        }
      }

      if (userData['email'] == null && fallbackEmail != null) {
        userData['email'] = fallbackEmail;
      }

      try {
        final existingUser = await storage.getUserModel();
        final newUserModel = UserModel.fromJson(userData);
        
        // If the new user model has an ID of 0 and no name/email, it's likely an empty shell
        // generated from a flat response with no user data (e.g. verify-otp without user object).
        // In that case, we don't want to completely overwrite our existing valid user.
        if (existingUser != null) {
          final mergedUser = existingUser.copyWith(
            id: newUserModel.id != 0 ? newUserModel.id : null,
            name: newUserModel.name.isNotEmpty ? newUserModel.name : null,
            email: newUserModel.email.isNotEmpty ? newUserModel.email : null,
            phone: newUserModel.phone?.isNotEmpty == true ? newUserModel.phone : null,
            institute: newUserModel.institute?.isNotEmpty == true ? newUserModel.institute : null,
            roleLevel: newUserModel.roleLevel != 0 ? newUserModel.roleLevel : null,
            role: newUserModel.role?.isNotEmpty == true ? newUserModel.role : null,
            roles: newUserModel.roles.isNotEmpty ? newUserModel.roles : null,
            avatar: newUserModel.avatar?.isNotEmpty == true ? newUserModel.avatar : null,
            passportNumber: newUserModel.passportNumber?.isNotEmpty == true ? newUserModel.passportNumber : null,
            studentClass: newUserModel.studentClass?.isNotEmpty == true ? newUserModel.studentClass : null,
            parentName: newUserModel.parentName?.isNotEmpty == true ? newUserModel.parentName : null,
            parentMobile: newUserModel.parentMobile?.isNotEmpty == true ? newUserModel.parentMobile : null,
          );
          await storage.saveUserModel(mergedUser);
        } else {
          await storage.saveUserModel(newUserModel);
        }
      } catch (e, stackTrace) {
        // Ignore if we can't parse user model completely, 
        // to avoid breaking login completely.
        debugPrint('Failed to parse user profile: $e');
        debugPrint(stackTrace.toString());
      }
    }
  }
}
