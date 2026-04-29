import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  static const String _displayNameKey = 'display_name';

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

  Future<void> saveDisplayName(String displayName) {
    return _storage.write(key: _displayNameKey, value: displayName.trim());
  }

  Future<String?> getDisplayName() => _storage.read(key: _displayNameKey);

  Future<void> clearDisplayName() {
    return _storage.delete(key: _displayNameKey);
  }
}
