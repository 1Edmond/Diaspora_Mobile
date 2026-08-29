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

  // Freelance escrow orchestration (calls Wallet gateway endpoints).
  Future<String> freelanceHold({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  });

  Future<void> freelanceRelease({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  });

  Future<void> freelanceRefund({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  });

  Future<void> freelancePay({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  });
}
