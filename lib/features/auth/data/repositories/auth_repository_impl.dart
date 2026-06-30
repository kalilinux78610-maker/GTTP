import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/data/auth_remote_datasource.dart';
import 'package:gttp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  @override
  Future<void> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      await _remoteDataSource.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed due to an unexpected error.');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send reset instructions.');
    }
  }

  @override
  Future<void> verifyOtp({required String otp}) async {
    try {
      await _remoteDataSource.verifyOtp(otp: otp);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to verify OTP.');
    }
  }

  @override
  Future<void> resendOtp() async {
    try {
      await _remoteDataSource.resendOtp();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to resend OTP.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to reset password.');
    }
  }

  @override
  Future<void> logout() async {
    // Always attempt server-side logout first to invalidate the JWT,
    // then clear local state regardless of outcome.
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore — local cleanup still proceeds.
    }
    await _secureStorage.clearTokens();
    await _secureStorage.clearPendingUserId();
    await _secureStorage.clearUserProfile();
  }

  @override
  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{'name': name};
      if (phone != null && phone.trim().isNotEmpty) {
        data['phone'] = phone.trim();
      }
      await _remoteDataSource.updateUserProfile(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update profile.');
    }
  }

  @override
  Future<void> uploadAvatar(String imagePath) async {
    try {
      await _remoteDataSource.uploadAvatar(imagePath);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to upload avatar.');
    }
  }
}
