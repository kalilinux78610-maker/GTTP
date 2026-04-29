abstract class AuthRepository {
  Future<void> login({
    required String usernameOrEmail,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  /// Reads [user_id] from secure storage (saved during login/forgotPassword)
  /// and verifies [otp] against the backend.
  Future<void> verifyOtp({required String otp});

  /// Resends the OTP to the currently pending user email.
  Future<void> resendOtp();

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<void> logout();
}
