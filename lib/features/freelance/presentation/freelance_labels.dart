import 'package:flutter/material.dart';
import '../domain/entities/enums.dart';

String jobPostingStatusLabel(JobPostingStatus s) {
  switch (s) {
    case JobPostingStatus.draft:
      return 'Brouillon';
    case JobPostingStatus.open:
      return 'Ouverte';
    case JobPostingStatus.registrationClosed:
      return 'Inscriptions closes';
    case JobPostingStatus.inProgress:
      return 'En cours';
    case JobPostingStatus.completed:
      return 'Terminée';
    case JobPostingStatus.cancelled:
      return 'Annulée';
  }
}

Color jobPostingStatusColor(JobPostingStatus s) {
  switch (s) {
    case JobPostingStatus.draft:
      return Colors.blueGrey;
    case JobPostingStatus.open:
      return const Color(0xFF16A34A);
    case JobPostingStatus.registrationClosed:
      return const Color(0xFFF59E0B);
    case JobPostingStatus.inProgress:
      return const Color(0xFF2563EB);
    case JobPostingStatus.completed:
      return const Color(0xFF7C3AED);
    case JobPostingStatus.cancelled:
      return const Color(0xFFDC2626);
  }
}

String jobApplicationStatusLabel(JobApplicationStatus s) {
  switch (s) {
    case JobApplicationStatus.pending:
      return 'En attente';
    case JobApplicationStatus.accepted:
      return 'Acceptée';
    case JobApplicationStatus.rejected:
      return 'Refusée';
    case JobApplicationStatus.withdrawn:
      return 'Retirée';
    case JobApplicationStatus.completed:
      return 'Terminée';
    case JobApplicationStatus.noShow:
      return 'Absent';
  }
}

Color jobApplicationStatusColor(JobApplicationStatus s) {
  switch (s) {
    case JobApplicationStatus.pending:
      return const Color(0xFFF59E0B);
    case JobApplicationStatus.accepted:
      return const Color(0xFF16A34A);
    case JobApplicationStatus.rejected:
      return const Color(0xFFDC2626);
    case JobApplicationStatus.withdrawn:
      return Colors.blueGrey;
    case JobApplicationStatus.completed:
      return const Color(0xFF7C3AED);
    case JobApplicationStatus.noShow:
      return const Color(0xFFDC2626);
  }
}

String paymentTypeLabel(PaymentType p) {
  switch (p) {
    case PaymentType.perHour:
      return 'À l\'heure';
    case PaymentType.perDay:
      return 'À la journée';
    case PaymentType.perTask:
      return 'À la mission';
    case PaymentType.fixed:
      return 'Forfait';
  }
}

String checkInMethodLabel(CheckInMethod m) {
  switch (m) {
    case CheckInMethod.qrCode:
      return 'QR code';
    case CheckInMethod.geoLocation:
      return 'Géolocalisation';
    case CheckInMethod.manualByEmployer:
      return 'Manuel (employeur)';
    case CheckInMethod.pinCode:
      return 'Code PIN';
    case CheckInMethod.any:
      return 'Libre';
  }
}