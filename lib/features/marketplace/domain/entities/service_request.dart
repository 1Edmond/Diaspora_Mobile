import 'package:flutter/material.dart';
import 'enums.dart';

class ServiceRequest {
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

  const ServiceRequest({
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

  ServiceRequest copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? requesterId,
    String? requesterName,
    String? providerId,
    String? providerName,
    String? message,
    ServiceRequestStatus? status,
    double? agreedPrice,
    String? agreedCurrency,
    PaymentStatus? paymentStatus,
    String? walletTransactionId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? chatThreadId,
    double? parcelWeightKg,
    String? parcelNature,
    double? declaredValue,
    String? pickupOtpCode,
    String? deliveryOtpCode,
    ParcelTrackingStep? trackingStep,
    String? departureCountryCode,
    String? departureCity,
    String? arrivalCountryCode,
    String? arrivalCity,
    DateTime? departureDate,
    DateTime? arrivalDate,
    String? pickupProofUrl,
    String? deliveryProofUrl,
    bool? isInDispute,
    String? disputeReason,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      message: message ?? this.message,
      status: status ?? this.status,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      agreedCurrency: agreedCurrency ?? this.agreedCurrency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      walletTransactionId: walletTransactionId ?? this.walletTransactionId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      chatThreadId: chatThreadId ?? this.chatThreadId,
      parcelWeightKg: parcelWeightKg ?? this.parcelWeightKg,
      parcelNature: parcelNature ?? this.parcelNature,
      declaredValue: declaredValue ?? this.declaredValue,
      pickupOtpCode: pickupOtpCode ?? this.pickupOtpCode,
      deliveryOtpCode: deliveryOtpCode ?? this.deliveryOtpCode,
      trackingStep: trackingStep ?? this.trackingStep,
      departureCountryCode: departureCountryCode ?? this.departureCountryCode,
      departureCity: departureCity ?? this.departureCity,
      arrivalCountryCode: arrivalCountryCode ?? this.arrivalCountryCode,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      pickupProofUrl: pickupProofUrl ?? this.pickupProofUrl,
      deliveryProofUrl: deliveryProofUrl ?? this.deliveryProofUrl,
      isInDispute: isInDispute ?? this.isInDispute,
      disputeReason: disputeReason ?? this.disputeReason,
    );
  }

  String getStatusLabel() {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'En attente';
      case ServiceRequestStatus.accepted:
        return 'Acceptée';
      case ServiceRequestStatus.declined:
        return 'Refusée';
      case ServiceRequestStatus.completed:
        return 'Complétée';
      case ServiceRequestStatus.cancelled:
        return 'Annulée';
      case ServiceRequestStatus.packageHandedOver:
        return 'Colis remis';
      case ServiceRequestStatus.inTransit:
        return 'En transit';
      case ServiceRequestStatus.arrivedAtDestination:
        return 'Arrivé à destination';
      case ServiceRequestStatus.delivered:
        return 'Livré';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.accepted:
        return Colors.blue;
      case ServiceRequestStatus.declined:
        return Colors.red;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.grey;
      case ServiceRequestStatus.packageHandedOver:
        return Colors.teal;
      case ServiceRequestStatus.inTransit:
        return Colors.indigo;
      case ServiceRequestStatus.arrivedAtDestination:
        return Colors.amber;
      case ServiceRequestStatus.delivered:
        return Colors.green;
    }
  }

  bool get hasChatThread => chatThreadId != null && chatThreadId!.isNotEmpty;

  String getFormattedPrice() {
    if (agreedPrice == null) return 'Prix non défini';
    return '${agreedPrice!.toStringAsFixed(agreedPrice! == agreedPrice!.toInt() ? 0 : 2)} ${agreedCurrency ?? "XOF"}';
  }
}