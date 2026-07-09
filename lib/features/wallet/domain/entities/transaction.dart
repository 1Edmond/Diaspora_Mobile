import 'package:diaspora_app/core/constants/enums.dart';
import 'currency.dart';

class Transaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final Currency currency;
  final Currency? fromCurrency;
  final Currency? toCurrency;
  final double? exchangeRate;
  final String? recipientId;
  final String? senderId;
  final String description;
  final TransactionStatus status;
  final double fee;
  final String reference;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.currency,
    this.fromCurrency,
    this.toCurrency,
    this.exchangeRate,
    this.recipientId,
    this.senderId,
    required this.description,
    required this.status,
    required this.fee,
    required this.reference,
    required this.timestamp,
  });
}
