import '../entities/transaction.dart';
import '../entities/currency.dart';

abstract class IWalletRepository {
  Future<Map<Currency, double>> getBalances();
  Future<List<Transaction>> getTransactions({int limit = 20});
  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  });
  Future<void> exchangeCurrency({
    required Currency from,
    required Currency to,
    required double amount,
  });
}
