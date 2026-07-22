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
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<bool> ensureAuthenticated();
}
