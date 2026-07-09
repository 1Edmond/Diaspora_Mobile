import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:diaspora_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:diaspora_app/core/network/dio_client.dart';

void main() {
  test('AuthNotifier register/verify/login (mocked) happy path', () async {
    final repo = AuthRepositoryImpl(client: DioClient());
    final notifier = AuthNotifier(repo);

    await notifier.register('+22890000000', 'password', 'BOURSIER');
    final afterRegister = notifier.state;
    expect(afterRegister.isLoading || afterRegister.hasValue, true);

    final ok = await notifier.verifyPhone('+22890000000', '123456');
    expect(ok, true);

    final logged = await notifier.login('+22890000000', 'password');
    expect(logged, true);
    expect(notifier.state.hasValue, true);
    expect(notifier.state.value!.togolesePhoneNumber, '+22890000000');
  });
}
