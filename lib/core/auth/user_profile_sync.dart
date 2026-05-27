import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/data/models/user_model.dart';

/// Reads `user` / `data.user` blocks from API JSON and persists profile fields.
class UserProfileSync {
  static Future<void> mergeFromApiResponse(
    SecureStorageService storage,
    Map<String, dynamic> response, {
    String? fallbackEmail,
  }) async {
    // Find the exact 'user' block from the payload
    dynamic userData = response['user'];
    if (userData == null && response['data'] != null && response['data'] is Map) {
      userData = response['data']['user'];
    }
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
        final userModel = UserModel.fromJson(userData);
        await storage.saveUserModel(userModel);
      } catch (e) {
        // Ignore if we can't parse user model completely, 
        // to avoid breaking login completely.
      }
    }
  }
}
