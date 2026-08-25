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
  });

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
      status: ServiceRequestStatus.values[_int(json, 'Status', 'status')],
      agreedPrice: _double(json, 'AgreedPrice', 'agreedPrice'),
      agreedCurrency: _strOrNull(json, 'AgreedCurrency', 'agreedCurrency'),
      paymentStatus: PaymentStatus.values[_int(json, 'PaymentStatus', 'paymentStatus')],
      walletTransactionId: _strOrNull(json, 'WalletTransactionId', 'walletTransactionId'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      acceptedAt: _parseDateTime(json, 'AcceptedAt', 'acceptedAt'),
      completedAt: _parseDateTime(json, 'CompletedAt', 'completedAt'),
      chatThreadId: _strOrNull(json, 'ChatThreadId', 'chatThreadId'),
    );
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
  };
}