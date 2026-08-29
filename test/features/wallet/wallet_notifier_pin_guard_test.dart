import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/wallet/presentation/controllers/wallet_notifier.dart';
import 'package:diaspora_app/features/wallet/domain/wallet_auth_service.dart';
import 'package:diaspora_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:diaspora_app/features/wallet/domain/entities/currency.dart';
import 'package:diaspora_app/features/wallet/domain/entities/transaction.dart';

class _FakeAuth implements IWalletAuthService {
  bool pinSet = false;
  String? _pin;
  bool biometricSucceeds = false;

  @override
  Future<void> clearPin() async {
    pinSet = false;
    _pin = null;
  }

  @override
  Future<bool> authenticateWithBiometrics({String reason = 'auth'}) async =>
      biometricSucceeds;

  @override
  Future<bool> canCheckBiometrics() async => true;

  @override
  Future<bool> isPinSet() async => pinSet;

  @override
  Future<void> setPin(String pin) async {
    pinSet = true;
    _pin = pin;
  }

  @override
  Future<bool> verifyPin(String pin) async => _pin == pin;
}

class _FakeRepo implements IWalletRepository {
  bool transferCalled = false;

  @override
  Future<Map<Currency, double>> getBalances() async => {};

  @override
  Future<List<Transaction>> getTransactions({int limit = 20}) async => [];

  @override
  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  }) async {
    transferCalled = true;
  }

  @override
  Future<void> exchangeCurrency({
    required Currency from,
    required Currency to,
    required double amount,
  }) async {}

  @override
  Future<String> freelanceHold({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async => 'tx_test';

  @override
  Future<void> freelanceRelease({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {}

  @override
  Future<void> freelanceRefund({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {}

  @override
  Future<void> freelancePay({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockCurrency = Currency(
    code: 'XOF',
    symbol: 'F',
    name: 'Franc',
    flag: '',
  );

  test('transferWithAuth blocks when PIN set and wrong PIN provided', () async {
    final auth = _FakeAuth();
    final repo = _FakeRepo();
    final notifier = WalletNotifier(repository: repo, authService: auth);

    await auth.setPin('9999');
    expect(await notifier.isPinSet(), true);

    expect(
      () async =>
          await notifier.transferWithAuth('u1', 100, mockCurrency, pin: '0000'),
      throwsA(isA<StateError>()),
    );
    expect(repo.transferCalled, false);
  });

  test('transferWithAuth allows when correct PIN provided', () async {
    final auth = _FakeAuth();
    final repo = _FakeRepo();
    final notifier = WalletNotifier(repository: repo, authService: auth);

    await auth.setPin('4242');
    await notifier.transferWithAuth('u1', 100, mockCurrency, pin: '4242');
    expect(repo.transferCalled, true);
  });

  test('transferWithAuth allows biometric when enabled and succeeds', () async {
    final auth = _FakeAuth();
    auth.biometricSucceeds = true;
    await auth.setPin('1111');

    final repo = _FakeRepo();
    final notifier = WalletNotifier(repository: repo, authService: auth);

    await notifier.transferWithAuth(
      'u1',
      50,
      mockCurrency,
      useBiometrics: true,
    );
    expect(repo.transferCalled, true);
  });
}
