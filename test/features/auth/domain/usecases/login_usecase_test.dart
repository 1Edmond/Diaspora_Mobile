import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:diaspora_app/features/auth/domain/repositories/auth_repository.dart';

class _FakeRepo implements IAuthRepository {
  @override
  Future<Map<String, dynamic>> login(String phone, String password) async {
    return {
      'user': {
        'id': 'u1',
        'name': 'Test',
        'phone': phone,
        'userType': 'BOURSIER',
        'status': 'validated',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String userType,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyPhone(String phone, String otp) async {
    throw UnimplementedError();
  }
}

void main() {
  test('LoginUseCase returns user map when repo succeeds', () async {
    final usecase = LoginUseCase(_FakeRepo());
    final res = await usecase.call('+22812345678', 'pwd');

    expect(res, isA<Map<String, dynamic>>());
    expect(res['user']['phone'], '+22812345678');
  });
}
