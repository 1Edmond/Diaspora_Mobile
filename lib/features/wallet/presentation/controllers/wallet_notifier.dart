import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/wallet_auth_service.dart';

import '../../../../core/di/injection.dart';

final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<Wallet?>>((ref) {
      return WalletNotifier(
        repository: getIt<IWalletRepository>(),
        authService: getIt<IWalletAuthService>(),
      );
    });

class WalletNotifier extends StateNotifier<AsyncValue<Wallet?>> {
  final IWalletRepository repository;
  final IWalletAuthService authService;

  WalletNotifier({
    required this.repository,
    required this.authService,
  }) : super(const AsyncValue.loading()) {
    loadBalance();
  }

  Future<void> loadBalance() async {
    state = const AsyncValue.loading();
    try {
      final balances = await repository.getBalances();
      final balanceMap = balances.map(
        (key, value) => MapEntry(key.code, value),
      );
      final wallet = Wallet(userId: 'current_user', balances: balanceMap);
      state = AsyncValue.data(wallet);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> isPinSet() async => authService.isPinSet();
  Future<void> setPin(String pin) async => authService.setPin(pin);
  Future<bool> verifyPin(String pin) async => authService.verifyPin(pin);
  Future<bool> canCheckBiometrics() async => authService.canCheckBiometrics();
  Future<bool> authenticateWithBiometrics() async =>
      authService.authenticateWithBiometrics();

  Future<void> transferWithAuth(
    String recipientId,
    double amount,
    Currency currency, {
    String? pin,
    bool useBiometrics = false,
    String? note,
  }) async {
    final pinSet = await authService.isPinSet();
    if (pinSet) {
      var ok = false;
      if (useBiometrics) {
        ok = await authService.authenticateWithBiometrics();
      } else {
        if (pin == null) throw ArgumentError('PIN required');
        ok = await authService.verifyPin(pin);
      }
      if (!ok) throw StateError('Authentication failed');
    }

    await repository.sendMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      note: note,
    );
    await loadBalance();
  }

  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  }) async {
    await repository.sendMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      note: note,
    );
    await loadBalance();
  }
}
