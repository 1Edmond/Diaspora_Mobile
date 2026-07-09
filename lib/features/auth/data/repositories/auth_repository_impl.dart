import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final DioClient _client;
  AuthRepositoryImpl({DioClient? client}) : _client = client ?? DioClient();

  @override
  Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String userType,
  ) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'phone': phone, 'password': password, 'userType': userType},
    );
    return res;
  }

  @override
  Future<bool> verifyPhone(String phone, String otp) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/auth/verify',
      data: {'phone': phone, 'otp': otp},
    );
    return (res['ok'] as bool?) ?? false;
  }

  @override
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return res;
  }
}
