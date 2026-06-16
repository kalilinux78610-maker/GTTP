import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gttp/features/auth/data/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  /// Factory that creates a platform-aware FlutterSecureStorage instance.
  /// On Web, flutter_secure_storage uses localStorage but requires WebOptions
  /// to be configured — otherwise all reads return null silently.
  static SecureStorageService create() {
    const storage = FlutterSecureStorage(
      // Web: store in localStorage with a named DB so keys don't clash
      webOptions: WebOptions(
        dbName: 'gttp_secure_store',
        publicKey: 'gttp_pk',
      ),
    );
    return SecureStorageService(storage);
  }

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _pendingUserIdKey = 'pending_user_id';
  static const String _displayNameKey = 'display_name'; // legacy key
  static const String _emailKey = 'email'; // legacy key
  static const String _phoneKey = 'phone'; // legacy key
  static const String _roleKey = 'role'; // legacy key
  static const String _instituteKey = 'institute'; // legacy key
  static const String _userProfileDataKey = 'user_profile_data';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> savePendingUserId(int userId) {
    return _storage.write(key: _pendingUserIdKey, value: userId.toString());
  }

  Future<int?> getPendingUserId() async {
    final value = await _storage.read(key: _pendingUserIdKey);
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  Future<void> clearPendingUserId() {
    return _storage.delete(key: _pendingUserIdKey);
  }

  Future<void> saveUserModel(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(key: _userProfileDataKey, value: jsonString);
  }

  Future<UserModel?> getUserModel() async {
    final jsonString = await _storage.read(key: _userProfileDataKey);
    if (jsonString == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserProfile() async {
    await _storage.delete(key: _userProfileDataKey);
    // Legacy keys cleanup
    await _storage.delete(key: _displayNameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _instituteKey);
  }

  Future<String?> getDisplayName() async {
    final user = await getUserModel();
    if (user != null && user.name.isNotEmpty) return user.name;
    // Fallback
    return _storage.read(key: _displayNameKey);
  }

  Future<void> saveDisplayName(String displayName) async {
    final user = await getUserModel();
    if (user != null) {
      final updatedUser = UserModel(
        id: user.id,
        name: displayName.trim(),
        email: user.email,
        emailVerifiedAt: user.emailVerifiedAt,
        phone: user.phone,
        passportNumber: user.passportNumber,
        passportExpiry: user.passportExpiry,
        roleLevel: user.roleLevel,
        isAlumni: user.isAlumni,
        avatar: user.avatar,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        deletedAt: user.deletedAt,
        schoolId: user.schoolId,
        institute: user.institute,
        role: user.role,
        studentClass: user.studentClass,
        parentName: user.parentName,
        parentMobile: user.parentMobile,
        instituteType: user.instituteType,
        roles: user.roles,
      );
      await saveUserModel(updatedUser);
    } else {
      await _storage.write(key: _displayNameKey, value: displayName.trim());
    }
  }

  Future<void> clearDisplayName() {
    return _storage.delete(key: _displayNameKey);
  }

  Future<List<int>> getOrCreateHiveKey() async {
    const String hiveKey = 'hive_encryption_key';
    String? existingKey = await _storage.read(key: hiveKey);
    if (existingKey == null) {
      final key = Hive.generateSecureKey();
      await _storage.write(key: hiveKey, value: base64UrlEncode(key));
      return key;
    }
    return base64Url.decode(existingKey);
  }
}
