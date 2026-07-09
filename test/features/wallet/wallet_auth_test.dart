import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:diaspora_app/features/wallet/data/wallet_auth_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Provide platform-channel mocks so this "integration-light" test
  // can run in CI without real platform plugins.
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  const authChannel = MethodChannel('plugins.flutter.io/local_auth');
  final Map<String, String?> storage = {};

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(storageChannel, (call) async {
        final args = call.arguments;
        String? key;
        dynamic value;
        if (args is Map) {
          key = args['key'] as String?;
          value = args['value'];
        } else if (args is String) {
          key = args;
        }

        switch (call.method) {
          case 'read':
            return storage[key];
          case 'write':
            storage[key!] = value as String?;
            return null;
          case 'delete':
            storage.remove(key);
            return null;
          default:
            return null;
        }
      });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(authChannel, (call) async {
        switch (call.method) {
          case 'canCheckBiometrics':
            return false;
          case 'authenticate':
            return false;
          default:
            return null;
        }
      });

  group('WalletAuthServiceImpl (integration-light)', () {
    final svc = WalletAuthServiceImpl();

    tearDown(() async {
      await svc.clearPin();
    });

    test('setPin / isPinSet / verifyPin', () async {
      expect(await svc.isPinSet(), false);
      await svc.setPin('1234');
      expect(await svc.isPinSet(), true);
      expect(await svc.verifyPin('1234'), true);
      expect(await svc.verifyPin('0000'), false);
    });

    test('biometric availability is safe to call', () async {
      // We only assert that the call completes without errors
      final can = await svc.canCheckBiometrics();
      expect(can, isA<bool>());
      final auth = await svc.authenticateWithBiometrics(reason: 'test');
      expect(auth, isA<bool>());
    });
  });
}
