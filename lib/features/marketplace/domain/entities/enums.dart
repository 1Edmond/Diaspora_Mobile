enum ListingSortBy {
  relevance,
  newest,
  ratingDesc,
  priceAsc,
  priceDesc,
  distance,
}

enum ReportTargetType {
  listing,
  review,
  user,
}

enum ReportStatus {
  pending,
  reviewed,
  dismissed,
  actionTaken,
}

enum ServiceRequestStatus {
  pending,              // 0
  accepted,             // 1
  declined,             // 2
  completed,            // 3
  cancelled,            // 4
  packageHandedOver,    // 5
  inTransit,            // 6
  arrivedAtDestination, // 7
  delivered,            // 8
}

enum PaymentStatus {
  notApplicable, // 0
  pending, // 1
  processing, // 2
  held, // 3
  completed, // 4 (Released)
  refunded, // 5
  failed, // 6
}

enum ParcelTrackingStep {
  bookingConfirmed, // 1. Réservation confirmée & Paiement sous séquestre
  parcelHandedOver, // 2. Colis remis au voyageur (validé par Code Remise OTP)
  inTransit,        // 3. En transit (vol/transport)
  arrivedAtDestination, // 4. Arrivé dans la ville de destination
  delivered,        // 5. Colis livré au destinataire (validé par Code Livraison OTP)
}