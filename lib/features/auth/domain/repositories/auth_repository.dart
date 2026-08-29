abstract class IAuthRepository {
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String userType,
  });
  Future<bool> verifyEmail(String email, String code);
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? deviceId,
  });
  Future<void> logout();
  Future<bool> ensureAuthenticated();

  /// The current (possibly refreshed) access token, or null if there is no
  /// valid session. Used outside the login flow itself — e.g. to enroll
  /// biometrics from the Settings screen, well after the original login.
  String? get accessToken;
}
