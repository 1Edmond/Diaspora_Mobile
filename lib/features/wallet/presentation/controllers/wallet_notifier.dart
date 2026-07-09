import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../data/repositories/wallet_repository_impl.dart';
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
  final IWalletRepository? repository;
  final IWalletAuthService? authService;

  WalletNotifier({required this.repository, required this.authService})
    : super(const AsyncValue.loading()) {
    loadBalance();
  }

  Future<void> loadBalance() async {
    state = const AsyncValue.loading();
    try {
      final repo = repository ?? WalletRepositoryImpl();
      final balances = await repo.getBalances();
      // V2 Repository returns Map<Currency, double>.
      // We assume current user context is handled by repository or irrelevant for mock.
      // Creating a Wallet entity wrapper for compatibility with state.

      // Convert Map<Currency, double> to Map<String, double> for Wallet entity
      final balanceMap = balances.map(
        (key, value) => MapEntry(key.code, value),
      );

      final wallet = Wallet(userId: 'current_user', balances: balanceMap);
      state = AsyncValue.data(wallet);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// PIN / biometric helpers (not obligate callers — fall back to in-memory
  /// behavior when DI isn't configured).
  Future<bool> isPinSet() async {
    final svc = authService ?? _InMemoryWalletAuth();
    return await svc.isPinSet();
  }

  Future<void> setPin(String pin) async {
    final svc = authService ?? _InMemoryWalletAuth();
    await svc.setPin(pin);
  }

  Future<bool> verifyPin(String pin) async {
    final svc = authService ?? _InMemoryWalletAuth();
    return await svc.verifyPin(pin);
  }

  Future<bool> canCheckBiometrics() async {
    final svc = authService ?? _InMemoryWalletAuth();
    return await svc.canCheckBiometrics();
  }

  Future<bool> authenticateWithBiometrics() async {
    final svc = authService ?? _InMemoryWalletAuth();
    return await svc.authenticateWithBiometrics();
  }

  /// Transfer wrapper that enforces PIN/biometric authentication when a PIN
  /// has been configured. Returns transfer response from repository on
  /// success, or throws on auth failure.
  Future<void> transferWithAuth(
    String recipientId,
    double amount,
    Currency currency, {
    String? pin,
    bool useBiometrics = false,
    String? note,
  }) async {
    final auth = authService ?? _InMemoryWalletAuth();

    final pinSet = await auth.isPinSet();
    if (pinSet) {
      var ok = false;
      if (useBiometrics) {
        ok = await auth.authenticateWithBiometrics();
      } else {
        if (pin == null) throw ArgumentError('PIN required');
        ok = await auth.verifyPin(pin);
      }
      if (!ok) throw StateError('Authentication failed');
    }

    final repo = repository ?? WalletRepositoryImpl();
    await repo.sendMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      note: note,
    );

    // refresh balance after transfer
    await loadBalance();
  }

  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  }) async {
    // For now, simpler direct call for the basic UI.
    // real implementation would likely reuse transferWithAuth or similar logic.
    final repo = repository ?? WalletRepositoryImpl();
    await repo.sendMoney(
      recipientId: recipientId,
      amount: amount,
      currency: currency,
      note: note,
    );
    await loadBalance();
  }
}

// Minimal in-memory fallback used in tests / when DI isn't configured.
class _InMemoryWalletAuth implements IWalletAuthService {
  String? _pin;

  @override
  Future<bool> authenticateWithBiometrics({String reason = 'auth'}) async =>
      false;

  @override
  Future<bool> canCheckBiometrics() async => false;

  @override
  Future<void> clearPin() async => _pin = null;

  @override
  Future<bool> isPinSet() async => _pin != null;

  @override
  Future<void> setPin(String pin) async => _pin = pin;

  @override
  Future<bool> verifyPin(String pin) async => _pin != null && _pin == pin;
}
