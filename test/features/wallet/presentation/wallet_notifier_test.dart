import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/wallet/presentation/controllers/wallet_notifier.dart';
import 'package:diaspora_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:diaspora_app/features/wallet/domain/wallet_auth_service.dart';
import 'package:diaspora_app/features/wallet/domain/entities/currency.dart';
import 'package:diaspora_app/features/wallet/domain/entities/transaction.dart';

class MockWalletRepository implements IWalletRepository {
  @override
  Future<Map<Currency, double>> getBalances() async => {
    Currency(code: 'XOF', symbol: 'CFA', name: 'XOF', flag: ''): 1000.0,
  };
  @override
  Future<List<Transaction>> getTransactions({int limit = 20}) async => [];
  @override
  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  }) async {}
  @override
  Future<void> exchangeCurrency({
    required Currency from,
    required Currency to,
    required double amount,
  }) async {}
}

class MockWalletAuth implements IWalletAuthService {
  @override
  Future<bool> authenticateWithBiometrics({String reason = 'auth'}) async =>
      true;
  @override
  Future<bool> canCheckBiometrics() async => true;
  @override
  Future<void> clearPin() async {}
  @override
  Future<bool> isPinSet() async => true;
  @override
  Future<void> setPin(String pin) async {}
  @override
  Future<bool> verifyPin(String pin) async => true;
}

void main() {
  test('WalletNotifier loads balance (mock)', () async {
    final mockRepo = MockWalletRepository();
    final mockAuth = MockWalletAuth();

    final notifier = WalletNotifier(
      repository: mockRepo,
      authService: mockAuth,
    );
    await notifier.loadBalance();

    final state = notifier.state;
    expect(state.hasValue || state.isLoading, true);
    expect(state.value, isNotNull);
    expect(state.value!.balances.containsKey('XOF'), true);
  });
}
