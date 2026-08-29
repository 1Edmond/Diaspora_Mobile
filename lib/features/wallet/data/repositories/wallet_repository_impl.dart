import '../../domain/entities/transaction.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../../../data/mock/mock_wallet_transactions.dart'; // Source
import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';

class WalletRepositoryImpl implements IWalletRepository {
  final DioClient _client;

  WalletRepositoryImpl({DioClient? client})
      : _client = client ?? DioClient();

  // Helpers to reconstruct Currency objects from codes would be needed in real app
  // For mock, we'll create simple Currency objects on the fly or fetch from a CurrencyRepository

  @override
  Future<Map<Currency, double>> getBalances() async {
    if (AppConfig.useMockData) {
      final result = <Currency, double>{};
      mockBalances.forEach((code, amount) {
        // Create dummy currency object for key
        // In real app, fetch standardized Currency entity
        final currency = Currency(
          code: code,
          symbol: _getSymbol(code),
          name: code,
          flag: '',
        );
        result[currency] = amount;
      });
      return result;
    }
    return {};
  }

  @override
  Future<List<Transaction>> getTransactions({int limit = 20}) async {
    if (AppConfig.useMockData) {
      return List<Transaction>.from(mockTransactions.take(limit));
    }
    return [];
  }

  @override
  Future<void> sendMoney({
    required String recipientId,
    required double amount,
    required Currency currency,
    String? note,
  }) async {
    if (AppConfig.useMockData) {
      // Check balance
      final currentBal = mockBalances[currency.code] ?? 0.0;
      if (currentBal < amount) {
        throw Exception('Insufficient funds');
      }

      // Deduct
      mockBalances[currency.code] = currentBal - amount;

      // Add Transaction
      // Note: importing Enums for TransactionType is needed but not shown in this specific file snippet context
      // assuming Enums are available or we add imports.
    }
  }

  @override
  Future<void> exchangeCurrency({
    required Currency from,
    required Currency to,
    required double amount,
  }) async {
    if (AppConfig.useMockData) {
      // Mock exchange logic
      final currentBal = mockBalances[from.code] ?? 0.0;
      if (currentBal < amount) throw Exception('Insufficient funds');

      final rate = _getMockRate(from.code, to.code);
      final converted = amount * rate;

      mockBalances[from.code] = currentBal - amount;
      mockBalances[to.code] = (mockBalances[to.code] ?? 0.0) + converted;
    }
  }

  @override
  Future<String> freelanceHold({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {
    final res = await _client.post('/transactions/freelance/hold', data: {
      'employerExternalProfileId': employerExternalProfileId,
      'jobApplicationId': jobApplicationId,
      'amount': amount,
      'description': description,
    });
    return (res as Map<String, dynamic>)['transactionId'] as String;
  }

  @override
  Future<void> freelanceRelease({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {
    await _client.post('/transactions/freelance/release', data: {
      'employerExternalProfileId': employerExternalProfileId,
      'workerExternalProfileId': workerExternalProfileId,
      'jobApplicationId': jobApplicationId,
      'amount': amount,
      'description': description,
    });
  }

  @override
  Future<void> freelanceRefund({
    required String employerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {
    await _client.post('/transactions/freelance/refund', data: {
      'employerExternalProfileId': employerExternalProfileId,
      'jobApplicationId': jobApplicationId,
      'amount': amount,
      'description': description,
    });
  }

  @override
  Future<void> freelancePay({
    required String employerExternalProfileId,
    required String workerExternalProfileId,
    required String jobApplicationId,
    required double amount,
    String? description,
  }) async {
    await _client.post('/transactions/freelance/pay', data: {
      'employerExternalProfileId': employerExternalProfileId,
      'workerExternalProfileId': workerExternalProfileId,
      'jobApplicationId': jobApplicationId,
      'amount': amount,
      'description': description,
    });
  }

  String _getSymbol(String code) {
    if (code == 'EUR') return '€';
    if (code == 'USD') return '\$';
    if (code == 'RUB') return '₽';
    return 'FCFA';
  }

  double _getMockRate(String from, String to) {
    if (from == 'RUB' && to == 'XOF') return 6.5;
    if (from == 'XOF' && to == 'RUB') return 0.15;
    return 1.0;
  }
}
