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
  });

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
    }
  }

  bool get hasChatThread => chatThreadId != null && chatThreadId!.isNotEmpty;

  String getFormattedPrice() {
    if (agreedPrice == null) return 'Prix non défini';
    return '${agreedPrice!.toStringAsFixed(agreedPrice! == agreedPrice!.toInt() ? 0 : 2)} ${agreedCurrency ?? "XOF"}';
  }
}