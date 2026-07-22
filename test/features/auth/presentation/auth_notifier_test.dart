import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:diaspora_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:diaspora_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:diaspora_app/features/profile/data/services/profile_service.dart';
import 'package:diaspora_app/shared/services/storage_service.dart';

Map<String, dynamic> _mockResponse(String path, Map<String, dynamic> data) {
  if (path.contains('register')) {
    return {'userId': 'u_0000', 'status': 'pending'};
  }
  if (path.contains('verify')) {
    return {'ok': data['Code'] == '123456'};
  }
  if (path.contains('login')) {
    return {
      'userId': 'u_0000',
      'user': {
        'id': 'u_0000',
        'email': 'test@email.com',
        'firstName': 'Test',
        'lastName': 'User',
        'role': ['User'],
        'status': 'Active',
        'emailVerified': true,
        'kycLevel': 'None',
        'phoneNumber': {'Value': '90000000', 'CountryCode': '+228'},
      },
      'role': ['User'],
      'accessToken': 'mock_token',
      'refreshToken': 'mock_refresh',
      'expiresAt': '2026-07-17T10:02:35Z',
    };
  }
  return {};
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(dir.path);
    await Hive.openBox('settings');
  });

  test('AuthNotifier register/verify/login happy path', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final data = options.data as Map<String, dynamic>? ?? {};
          handler.resolve(
            Response(
              requestOptions: options,
              data: _mockResponse(options.path, data),
              statusCode: 200,
            ),
          );
        },
      ),
    );

    final repo = AuthRepositoryImpl(client: dio);
    final notifier = AuthNotifier(
      repo,
      ProfileService(dio: Dio()),
      storage: StorageService(),
    );

    await notifier.register(
      phone: '+22890000000',
      password: 'password',
      firstName: 'Jean',
      lastName: 'Test',
      email: 'jean.test@email.com',
      dateOfBirth: DateTime(2000, 1, 15),
      userType: 'BOURSIER',
    );
    final afterRegister = notifier.state;
    expect(afterRegister.isLoading || afterRegister.hasValue, true);

    final ok = await notifier.verifyEmail('jean.test@email.com', '123456');
    expect(ok, true);

    final logged = await notifier.login('test@email.com', 'password');
    expect(logged, true);
    expect(notifier.state.hasValue, true);
    expect(notifier.state.value!.email, 'test@email.com');
    expect(notifier.state.value!.email, 'test@email.com');
    expect(notifier.state.value!.togolesePhoneNumber, '+22890000000');
  });
}
