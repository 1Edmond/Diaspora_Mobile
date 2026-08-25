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
  pending,
  accepted,
  declined,
  completed,
  cancelled,
}

enum PaymentStatus {
  notApplicable,
  pending,
  completed,
  refunded,
  failed,
}