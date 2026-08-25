import 'package:flutter/material.dart';
import 'enums.dart';

class Report {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reporterId;
  final String reason;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolutionNotes;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reporterId,
    required this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNotes,
    required this.createdAt,
  });

  Report copyWith({
    String? id,
    ReportTargetType? targetType,
    String? targetId,
    String? reporterId,
    String? reason,
    ReportStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? resolutionNotes,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reporterId: reporterId ?? this.reporterId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getTargetTypeLabel() {
    switch (targetType) {
      case ReportTargetType.listing:
        return 'Annonce';
      case ReportTargetType.review:
        return 'Avis';
      case ReportTargetType.user:
        return 'Utilisateur';
    }
  }

  String getStatusLabel() {
    switch (status) {
      case ReportStatus.pending:
        return 'En attente';
      case ReportStatus.reviewed:
        return 'Examined';
      case ReportStatus.dismissed:
        return 'Classé sans suite';
      case ReportStatus.actionTaken:
        return 'Action entreprise';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.reviewed:
        return Colors.blue;
      case ReportStatus.dismissed:
        return Colors.grey;
      case ReportStatus.actionTaken:
        return Colors.red;
    }
  }

  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}