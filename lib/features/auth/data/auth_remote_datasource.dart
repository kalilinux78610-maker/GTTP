import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gttp/core/auth/user_profile_sync.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/security/secure_storage_service.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient, this._secureStorage);

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    // Clear any old state before starting a new login session
    await _secureStorage.clearTokens();
    await _secureStorage.clearPendingUserId();
    await _secureStorage.clearUserProfile();

    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': usernameOrEmail, 'password': password},
    );

    // Try every common token key across flat and nested structures
    final accessToken = _readString(
      response,
      keys: ['accessToken', 'token', 'access_token', 'jwt', 'bearerToken'],
    );
    final refreshToken = _readString(
      response,
      keys: ['refreshToken', 'refresh_token', 'refreshJwt'],
    );

    /// OTP / verify-otp step only — do not use generic `id` (e.g. from `user`)
    /// or token+logins that include `user.id` will be mistaken for an OTP session.
    final userIdForOtp = _readInt(response, keys: ['user_id', 'userId']);
    final displayName = _readString(
      response,
      keys: [
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ],
    );
    final otpRequired = _readBool(
      response,
      keys: [
        'otp_required',
        'requires_otp',
        'mfa_required',
        'two_factor_required',
      ],
    );

    // Fallback logic for first_name and last_name
    String? finalDisplayName = displayName;
    if (finalDisplayName == null || finalDisplayName.isEmpty) {
      final firstName = _readString(
        response,
        keys: ['first_name', 'firstName'],
      );
      final lastName = _readString(response, keys: ['last_name', 'lastName']);
      if (firstName != null && firstName.isNotEmpty) {
        finalDisplayName = [
          firstName,
          lastName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[AuthDataSource] Parsed → accessToken: ${accessToken != null ? "found" : "null"}, '
        'userIdForOtp: $userIdForOtp',
      );
    }

    // Save pending user_id if returned (needed for 2FA verify-otp)
    if (userIdForOtp != null) {
      await _secureStorage.savePendingUserId(userIdForOtp);
    }
    await _saveDisplayName(finalDisplayName, fallbackEmail: usernameOrEmail);
    await UserProfileSync.mergeFromApiResponse(
      _secureStorage,
      response,
      fallbackEmail: usernameOrEmail,
    );

    // If backend explicitly asks for OTP, force verify-otp flow even if token
    // is present in the response.
    if (otpRequired == true) {
      return;
    }

    // Same response contains both user_id (OTP step) and a token — do not store
    // the token yet; user must complete verify-otp first (avoids "logged in" while OTP is still pending).
    if (userIdForOtp != null && accessToken != null && accessToken.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[AuthDataSource] user_id + token together — deferring token until verify-otp',
        );
      }
      return;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      // Finished session — do not keep a stale OTP user_id alongside the token.
      await _secureStorage.clearPendingUserId();
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      try {
        await fetchMe();
      } catch (e) {
        if (kDebugMode) debugPrint('[AuthDataSource] Failed to fetch profile during login: $e');
      }
      return;
    }

    // Backend may require OTP verification before issuing a token
    if (userIdForOtp != null) {
      return; // 2FA flow — navigate to verify-otp
    }

    final errorMessage = _readString(response, keys: ['message', 'error']);
    throw ApiException(
      errorMessage ?? 'Unexpected login response. Please contact support.',
      statusCode: 200,
    );
  }

  Future<void> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      data: {'email': email},
    );

    final userIdForOtp = _readInt(response, keys: ['user_id', 'userId']);
    if (userIdForOtp != null) {
      await _secureStorage.savePendingUserId(userIdForOtp);
      return;
    }

    // Check for explicit failure status or 'error' key instead of blinding throwing on 'message'
    final success = _readBool(response, keys: ['status', 'success']);
    if (success == false) {
      final errorMessage = _readString(response, keys: ['message', 'error']);
      throw ApiException(errorMessage ?? 'Request failed', statusCode: 200);
    } else if (success == null) {
      final errorStr = _readString(response, keys: ['error']);
      if (errorStr != null && errorStr.isNotEmpty) {
        throw ApiException(errorStr, statusCode: 200);
      }
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    final userId = await _secureStorage.getPendingUserId();
    if (userId == null) {
      throw ApiException(
        'Session expired. Please start again.',
        statusCode: 401,
      );
    }

    final response = await _apiClient.post(
      '/auth/verify-otp',
      data: {'user_id': userId, 'otp': otp},
    );

    // If the verify-otp response also returns a token, save it
    final accessToken = _readString(
      response,
      keys: ['accessToken', 'token', 'access_token', 'jwt'],
    );
    final displayName = _readString(
      response,
      keys: [
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ],
    );
    final email = _readString(response, keys: ['email', 'user_email']);

    String? finalDisplayName = displayName;
    if (finalDisplayName == null || finalDisplayName.isEmpty) {
      final firstName = _readString(
        response,
        keys: ['first_name', 'firstName'],
      );
      final lastName = _readString(response, keys: ['last_name', 'lastName']);
      if (firstName != null && firstName.isNotEmpty) {
        finalDisplayName = [
          firstName,
          lastName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
      }
    }

    await _saveDisplayName(finalDisplayName, fallbackEmail: email);
    await UserProfileSync.mergeFromApiResponse(
      _secureStorage,
      response,
      fallbackEmail: email,
    );

      // Check for explicit failure status or 'error' key instead of blinding throwing on 'message'
      final success = _readBool(response, keys: ['status', 'success']);
      if (success == false) {
        final errorMessage = _readString(response, keys: ['message', 'error']);
        throw ApiException(errorMessage ?? 'Failed to verify OTP', statusCode: 200);
      } else if (success == null) {
        final errorStr = _readString(response, keys: ['error']);
        if (errorStr != null && errorStr.isNotEmpty) {
          throw ApiException(errorStr, statusCode: 200);
        }
      }
      
      // If we reach here and there is no token AND no error message, something is very wrong.
      if (accessToken == null || accessToken.isEmpty) {
        throw ApiException('Unexpected response from server.', statusCode: 200);
      }

    // Clear pending user_id after successful OTP verification (we assume success if we reach here without throwing error)
    await _secureStorage.clearPendingUserId();

    final refreshToken = _readString(
      response,
      keys: ['refreshToken', 'refresh_token'],
    );
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    try {
      await fetchMe();
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthDataSource] Failed to fetch profile during verifyOtp: $e');
    }
  }

  Future<void> _saveDisplayName(
    String? displayName, {
    String? fallbackEmail,
  }) async {
    final normalized = displayName?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      await _secureStorage.saveDisplayName(normalized);
      return;
    }

    if (fallbackEmail != null && fallbackEmail.contains('@')) {
      final localPart = fallbackEmail.split('@').first.trim();
      if (localPart.isNotEmpty) {
        final readable = localPart
            .replaceAll(RegExp(r'[._-]+'), ' ')
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map(
              (part) => part[0].toUpperCase() + part.substring(1).toLowerCase(),
            )
            .join(' ');
        if (readable.isNotEmpty) {
          await _secureStorage.saveDisplayName(readable);
        }
      }
    }
  }

  Future<void> resendOtp() async {
    final userId = await _secureStorage.getPendingUserId();
    if (userId == null) {
      throw ApiException(
        'Session expired. Please log in again.',
        statusCode: 401,
      );
    }

    // Create FormData because Postman request body mode was "formdata"
    final formData = FormData.fromMap({'user_id': userId.toString()});

    final response = await _apiClient.post('/auth/resend-otp', data: formData);

    // Check for explicit failure status or 'error' key instead of blinding throwing on 'message'
    final success = _readBool(response, keys: ['status', 'success']);
    if (success == false) {
      final errorMessage = _readString(response, keys: ['message', 'error']);
      throw ApiException(errorMessage ?? 'Request failed', statusCode: 200);
    } else if (success == null) {
      final errorStr = _readString(response, keys: ['error']);
      if (errorStr != null && errorStr.isNotEmpty) {
        throw ApiException(errorStr, statusCode: 200);
      }
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );

    // Check for explicit failure status or 'error' key instead of blinding throwing on 'message'
    final success = _readBool(response, keys: ['status', 'success']);
    if (success == false) {
      final errorMessage = _readString(response, keys: ['message', 'error']);
      throw ApiException(errorMessage ?? 'Failed to reset password', statusCode: 200);
    } else if (success == null) {
      final errorStr = _readString(response, keys: ['error']);
      if (errorStr != null && errorStr.isNotEmpty) {
        throw ApiException(errorStr, statusCode: 200);
      }
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout', requiresAuth: true);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuthDataSource] Server logout failed: $e');
      // Continue to clear local tokens even if the server call fails.
    } finally {
      await _secureStorage.clearTokens();
      await _secureStorage.clearPendingUserId();
      await _secureStorage.clearUserProfile();
    }
  }

  Future<void> fetchMe() async {
    final response = await _apiClient.get('/auth/me', requiresAuth: true);
    
    final email = _readString(response, keys: ['email', 'user_email']);
    final displayName = _readString(
      response,
      keys: [
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ],
    );

    String? finalDisplayName = displayName;
    if (finalDisplayName == null || finalDisplayName.isEmpty) {
      final firstName = _readString(
        response,
        keys: ['first_name', 'firstName'],
      );
      final lastName = _readString(response, keys: ['last_name', 'lastName']);
      if (firstName != null && firstName.isNotEmpty) {
        finalDisplayName = [
          firstName,
          lastName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
      }
    }

    await _saveDisplayName(finalDisplayName, fallbackEmail: email);
    await UserProfileSync.mergeFromApiResponse(
      _secureStorage,
      response,
      fallbackEmail: email,
    );
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _apiClient.put('/auth/profile', data: data, requiresAuth: true);
    // After update, fetch the latest profile data
    await fetchMe();
  }

  Future<void> uploadAvatar(String imagePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imagePath),
    });
    
    await _apiClient.post(
      '/auth/profile/avatar',
      data: formData,
      requiresAuth: true,
    );
    // After upload, fetch the latest profile data
    await fetchMe();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Searches [response] (flat + inside 'data' and 'user' keys) for any of [keys].
  String? _readString(
    Map<String, dynamic> response, {
    required List<String> keys,
  }) {
    final sources = _buildSources(response);
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  /// Searches [response] for an integer value under any of [keys].
  int? _readInt(Map<String, dynamic> response, {required List<String> keys}) {
    final sources = _buildSources(response);
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return null;
  }

  /// Searches [response] for a boolean value under any of [keys].
  bool? _readBool(Map<String, dynamic> response, {required List<String> keys}) {
    final sources = _buildSources(response);
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          final normalized = value.trim().toLowerCase();
          if (normalized == 'true' || normalized == '1') return true;
          if (normalized == 'false' || normalized == '0') return false;
        }
      }
    }
    return null;
  }

  /// Builds a list of maps to search: root, root['data'], root['data']['user'].
  List<Map<String, dynamic>> _buildSources(Map<String, dynamic> response) {
    final sources = <Map<String, dynamic>>[response];

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      sources.add(data);
      final user = data['user'];
      if (user is Map<String, dynamic>) sources.add(user);
    }

    final user = response['user'];
    if (user is Map<String, dynamic>) sources.add(user);

    return sources;
  }
}
