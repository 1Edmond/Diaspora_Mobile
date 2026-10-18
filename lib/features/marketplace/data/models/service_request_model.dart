import '../../domain/entities/enums.dart';

class ServiceRequestModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String requesterId;
  final String requesterName;
  final String providerId;
  final String providerName;
  final String message;
  final ServiceRequestStatus status;
  final double? agreedPrice;
  final String? agreedCurrency;
  final PaymentStatus paymentStatus;
  final String? walletTransactionId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? chatThreadId;

  // Parcel / Travel tracking fields
  final double? parcelWeightKg;
  final String? parcelNature;
  final double? declaredValue;
  final String? pickupOtpCode;
  final String? deliveryOtpCode;
  final ParcelTrackingStep trackingStep;
  final String? departureCountryCode;
  final String? departureCity;
  final String? arrivalCountryCode;
  final String? arrivalCity;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final String? pickupProofUrl;
  final String? deliveryProofUrl;
  final bool isInDispute;
  final String? disputeReason;

  const ServiceRequestModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.requesterId,
    required this.requesterName,
    required this.providerId,
    required this.providerName,
    required this.message,
    required this.status,
    this.agreedPrice,
    this.agreedCurrency,
    required this.paymentStatus,
    this.walletTransactionId,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.chatThreadId,
    this.parcelWeightKg,
    this.parcelNature,
    this.declaredValue,
    this.pickupOtpCode,
    this.deliveryOtpCode,
    this.trackingStep = ParcelTrackingStep.bookingConfirmed,
    this.departureCountryCode,
    this.departureCity,
    this.arrivalCountryCode,
    this.arrivalCity,
    this.departureDate,
    this.arrivalDate,
    this.pickupProofUrl,
    this.deliveryProofUrl,
    this.isInDispute = false,
    this.disputeReason,
  });

  bool get isParcelRequest => parcelWeightKg != null && parcelWeightKg! > 0;

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: _str(json, 'Id', 'id'),
      listingId: _str(json, 'ListingId', 'listingId'),
      listingTitle: _str(json, 'ListingTitle', 'listingTitle'),
      requesterId: _str(json, 'RequesterId', 'requesterId'),
      requesterName: _str(json, 'RequesterName', 'requesterName'),
      providerId: _str(json, 'ProviderId', 'providerId'),
      providerName: _str(json, 'ProviderName', 'providerName'),
      message: _str(json, 'Message', 'message'),
      status: _parseStatus(json),
      agreedPrice: _double(json, 'AgreedPrice', 'agreedPrice'),
      agreedCurrency: _strOrNull(json, 'AgreedCurrency', 'agreedCurrency'),
      paymentStatus: _parsePaymentStatus(json),
      walletTransactionId: _strOrNull(json, 'WalletTransactionId', 'walletTransactionId'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      acceptedAt: _parseDateTime(json, 'AcceptedAt', 'acceptedAt'),
      completedAt: _parseDateTime(json, 'CompletedAt', 'completedAt'),
      chatThreadId: _strOrNull(json, 'ChatThreadId', 'chatThreadId'),
      parcelWeightKg: _double(json, 'ParcelWeightKg', 'parcelWeightKg'),
      parcelNature: _strOrNull(json, 'ParcelNature', 'parcelNature'),
      declaredValue: _double(json, 'DeclaredValue', 'declaredValue'),
      pickupOtpCode: _strOrNull(json, 'HandoverOtpCode', 'handoverOtpCode') ??
          _strOrNull(json, 'PickupOtpCode', 'pickupOtpCode'),
      deliveryOtpCode: _strOrNull(json, 'DeliveryOtpCode', 'deliveryOtpCode'),
      trackingStep: _parseTrackingStep(json),
      departureCountryCode: _strOrNull(json, 'DepartureCountryCode', 'departureCountryCode'),
      departureCity: _strOrNull(json, 'DepartureCity', 'departureCity'),
      arrivalCountryCode: _strOrNull(json, 'ArrivalCountryCode', 'arrivalCountryCode'),
      arrivalCity: _strOrNull(json, 'ArrivalCity', 'arrivalCity'),
      departureDate: _parseDateTime(json, 'DepartureDate', 'departureDate'),
      arrivalDate: _parseDateTime(json, 'ArrivalDate', 'arrivalDate'),
      pickupProofUrl: _strOrNull(json, 'HandoverProofUrl', 'handoverProofUrl') ??
          _strOrNull(json, 'PickupProofUrl', 'pickupProofUrl'),
      deliveryProofUrl: _strOrNull(json, 'DeliveryProofUrl', 'deliveryProofUrl'),
      isInDispute: _bool(json, 'IsInDispute', 'isInDispute'),
      disputeReason: _strOrNull(json, 'DisputeReason', 'disputeReason'),
    );
  }

  static ParcelTrackingStep _parseTrackingStep(Map<String, dynamic> json) {
    final status = _parseStatus(json);
    switch (status) {
      case ServiceRequestStatus.packageHandedOver:
        return ParcelTrackingStep.parcelHandedOver;
      case ServiceRequestStatus.inTransit:
        return ParcelTrackingStep.inTransit;
      case ServiceRequestStatus.arrivedAtDestination:
        return ParcelTrackingStep.arrivedAtDestination;
      case ServiceRequestStatus.delivered:
      case ServiceRequestStatus.completed:
        return ParcelTrackingStep.delivered;
      case ServiceRequestStatus.accepted:
      case ServiceRequestStatus.pending:
      case ServiceRequestStatus.declined:
      case ServiceRequestStatus.cancelled:
        break;
    }

    final val = json['TrackingStep'] ?? json['trackingStep'];
    if (val is int && val >= 0 && val < ParcelTrackingStep.values.length) {
      return ParcelTrackingStep.values[val];
    }
    if (val is String) {
      return ParcelTrackingStep.values.firstWhere(
        (e) => e.name.toLowerCase() == val.toLowerCase(),
        orElse: () => ParcelTrackingStep.bookingConfirmed,
      );
    }
    return ParcelTrackingStep.bookingConfirmed;
  }

  bool get canPay =>
      status == ServiceRequestStatus.accepted &&
      (paymentStatus == PaymentStatus.pending || paymentStatus == PaymentStatus.failed) &&
      (agreedPrice != null && agreedPrice! > 0);

  bool get isHeld => paymentStatus == PaymentStatus.held;
  bool get isProcessing => paymentStatus == PaymentStatus.processing;

  static ServiceRequestStatus _parseStatus(Map<String, dynamic> json) {
    final val = json['Status'] ?? json['status'];
    if (val is int && val >= 0 && val < ServiceRequestStatus.values.length) {
      return ServiceRequestStatus.values[val];
    }
    if (val is String) {
      return ServiceRequestStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == val.toLowerCase(),
        orElse: () => ServiceRequestStatus.pending,
      );
    }
    return ServiceRequestStatus.pending;
  }

  static PaymentStatus _parsePaymentStatus(Map<String, dynamic> json) {
    final val = json['PaymentStatus'] ?? json['paymentStatus'];
    if (val is int && val >= 0 && val < PaymentStatus.values.length) {
      return PaymentStatus.values[val];
    }
    if (val is String) {
      final s = val.toLowerCase();
      if (s == 'released') return PaymentStatus.completed;
      return PaymentStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == s,
        orElse: () => PaymentStatus.notApplicable,
      );
    }
    return PaymentStatus.notApplicable;
  }

  static String _str(Map<String, dynamic> json, String pascal, String camel) {
    return (json[pascal] ?? json[camel] ?? '') as String;
  }

  static String? _strOrNull(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return val as String;
  }

  static int _int(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0;
    return (val as num).toInt();
  }

  static double? _double(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return (val as num).toDouble();
  }

  static bool _bool(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return val == 1;
  }

  static DateTime? _parseDateTime(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ListingId': listingId,
    'ListingTitle': listingTitle,
    'RequesterId': requesterId,
    'RequesterName': requesterName,
    'ProviderId': providerId,
    'ProviderName': providerName,
    'Message': message,
    'Status': status.index,
    'AgreedPrice': agreedPrice,
    'AgreedCurrency': agreedCurrency,
    'PaymentStatus': paymentStatus.index,
    'WalletTransactionId': walletTransactionId,
    'CreatedAt': createdAt.toIso8601String(),
    'AcceptedAt': acceptedAt?.toIso8601String(),
    'CompletedAt': completedAt?.toIso8601String(),
    'ChatThreadId': chatThreadId,
    'ParcelWeightKg': parcelWeightKg,
    'ParcelNature': parcelNature,
    'DeclaredValue': declaredValue,
    'PickupOtpCode': pickupOtpCode,
    'DeliveryOtpCode': deliveryOtpCode,
    'TrackingStep': trackingStep.index,
    'DepartureCountryCode': departureCountryCode,
    'DepartureCity': departureCity,
    'ArrivalCountryCode': arrivalCountryCode,
    'ArrivalCity': arrivalCity,
    'DepartureDate': departureDate?.toIso8601String(),
    'ArrivalDate': arrivalDate?.toIso8601String(),
    'PickupProofUrl': pickupProofUrl,
    'DeliveryProofUrl': deliveryProofUrl,
    'IsInDispute': isInDispute,
    'DisputeReason': disputeReason,
  };
}