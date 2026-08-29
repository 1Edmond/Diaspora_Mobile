import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:diaspora_app/features/auth/domain/repositories/auth_repository.dart';

class _FakeRepo implements IAuthRepository {
  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    String? deviceId,
  }) async {
    return {
      'user': {
        'id': 'u1',
        'name': 'Test',
        'email': email,
        'userType': 'BOURSIER',
        'status': 'validated',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String userType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyEmail(String email, String code) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> ensureAuthenticated() async => false;

  @override
  String? get accessToken => null;
}

void main() {
  test('LoginUseCase returns user map when repo succeeds', () async {
    final usecase = LoginUseCase(_FakeRepo());
    final res = await usecase.call('test@email.com', 'pwd');

    expect(res, isA<Map<String, dynamic>>());
    expect(res['user']['email'], 'test@email.com');
  });
}
