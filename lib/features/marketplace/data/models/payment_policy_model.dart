import '../../domain/entities/enums.dart';

class PaymentPolicyModel {
  final String id;
  final String profileTypeId;
  final String countryCode;
  final AllowedSettlementPolicy allowedPolicy;
  final DirectCashTiming defaultCashTiming;
  final bool directBookingFeeEnabled;
  final double directBookingFeeFixedAmount;
  final double directBookingFeeRate;
  final String currency;
  final bool isActive;

  const PaymentPolicyModel({
    required this.id,
    required this.profileTypeId,
    required this.countryCode,
    this.allowedPolicy = AllowedSettlementPolicy.both,
    this.defaultCashTiming = DirectCashTiming.atPickup,
    this.directBookingFeeEnabled = false,
    this.directBookingFeeFixedAmount = 0.0,
    this.directBookingFeeRate = 0.0,
    this.currency = 'XOF',
    this.isActive = true,
  });

  factory PaymentPolicyModel.fromJson(Map<String, dynamic> json) {
    return PaymentPolicyModel(
      id: json['id']?.toString() ?? '',
      profileTypeId: json['profileTypeId']?.toString() ?? '',
      countryCode: json['countryCode']?.toString() ?? '',
      allowedPolicy: _parseAllowedPolicy(json['allowedPolicy']),
      defaultCashTiming: _parseCashTiming(json['defaultCashTiming']),
      directBookingFeeEnabled: json['directBookingFeeEnabled'] == true,
      directBookingFeeFixedAmount:
          (json['directBookingFeeFixedAmount'] as num?)?.toDouble() ?? 0.0,
      directBookingFeeRate:
          (json['directBookingFeeRate'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'XOF',
      isActive: json['isActive'] != false,
    );
  }

  static AllowedSettlementPolicy _parseAllowedPolicy(dynamic value) {
    if (value == null) return AllowedSettlementPolicy.both;
    if (value is int) {
      switch (value) {
        case 0:
          return AllowedSettlementPolicy.walletEscrowOnly;
        case 1:
          return AllowedSettlementPolicy.directHandoverOnly;
        default:
          return AllowedSettlementPolicy.both;
      }
    }
    final s = value.toString().toLowerCase();
    if (s.contains('escrow') || s == '0') return AllowedSettlementPolicy.walletEscrowOnly;
    if (s.contains('direct') || s == '1') return AllowedSettlementPolicy.directHandoverOnly;
    return AllowedSettlementPolicy.both;
  }

  static DirectCashTiming _parseCashTiming(dynamic value) {
    if (value == null) return DirectCashTiming.atPickup;
    if (value is int) {
      switch (value) {
        case 1:
          return DirectCashTiming.atDelivery;
        case 2:
          return DirectCashTiming.freeChoice;
        default:
          return DirectCashTiming.atPickup;
      }
    }
    final s = value.toString().toLowerCase();
    if (s.contains('delivery') || s == '1') return DirectCashTiming.atDelivery;
    if (s.contains('free') || s == '2') return DirectCashTiming.freeChoice;
    return DirectCashTiming.atPickup;
  }

  /// Calcule dynamiquement les frais de réservation plateforme selon le prix convenu
  double calculateDirectPlatformFee(double agreedPrice) {
    if (!directBookingFeeEnabled) return 0.0;
    final percentagePart = agreedPrice * directBookingFeeRate;
    final total = directBookingFeeFixedAmount + percentagePart;
    return double.parse(total.toStringAsFixed(2));
  }

  /// Valeur par défaut quand le réseau est inaccessible ou non configuré
  factory PaymentPolicyModel.defaultPolicy({String countryCode = 'TG'}) {
    return PaymentPolicyModel(
      id: '',
      profileTypeId: '',
      countryCode: countryCode,
      allowedPolicy: AllowedSettlementPolicy.both,
      defaultCashTiming: DirectCashTiming.atPickup,
      directBookingFeeEnabled: false,
      directBookingFeeFixedAmount: 0.0,
      directBookingFeeRate: 0.0,
      currency: 'XOF',
      isActive: true,
    );
  }
}
