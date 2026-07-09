import 'currency.dart';

class ExchangeRate {
  final Currency fromCurrency;
  final Currency toCurrency;
  final double rate;
  final DateTime lastUpdated;

  ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
  });
}
