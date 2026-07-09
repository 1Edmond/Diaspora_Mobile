abstract class IAuthRepository {
  Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String userType,
  );
  Future<bool> verifyPhone(String phone, String otp);
  Future<Map<String, dynamic>> login(String phone, String password);
}
