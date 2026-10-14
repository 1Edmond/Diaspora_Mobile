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
  notApplicable, // 0
  pending, // 1
  processing, // 2
  held, // 3
  completed, // 4 (Released)
  refunded, // 5
  failed, // 6
}