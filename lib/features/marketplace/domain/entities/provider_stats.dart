class ProviderStats {
  final int totalListings;
  final int activeListings;
  final int totalRequestsReceived;
  final int acceptedRequests;
  final int completedRequests;
  final double acceptanceRatePercent;
  final double? averageResponseTimeHours;
  final double totalRevenueCompleted;
  final double averageRating;
  final int totalReviews;
  final int totalFavorites;

  const ProviderStats({
    required this.totalListings,
    required this.activeListings,
    required this.totalRequestsReceived,
    required this.acceptedRequests,
    required this.completedRequests,
    required this.acceptanceRatePercent,
    this.averageResponseTimeHours,
    required this.totalRevenueCompleted,
    required this.averageRating,
    required this.totalReviews,
    required this.totalFavorites,
  });

  ProviderStats copyWith({
    int? totalListings,
    int? activeListings,
    int? totalRequestsReceived,
    int? acceptedRequests,
    int? completedRequests,
    double? acceptanceRatePercent,
    double? averageResponseTimeHours,
    double? totalRevenueCompleted,
    double? averageRating,
    int? totalReviews,
    int? totalFavorites,
  }) {
    return ProviderStats(
      totalListings: totalListings ?? this.totalListings,
      activeListings: activeListings ?? this.activeListings,
      totalRequestsReceived: totalRequestsReceived ?? this.totalRequestsReceived,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      completedRequests: completedRequests ?? this.completedRequests,
      acceptanceRatePercent: acceptanceRatePercent ?? this.acceptanceRatePercent,
      averageResponseTimeHours: averageResponseTimeHours ?? this.averageResponseTimeHours,
      totalRevenueCompleted: totalRevenueCompleted ?? this.totalRevenueCompleted,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalFavorites: totalFavorites ?? this.totalFavorites,
    );
  }

  String getFormattedAcceptanceRate() {
    return acceptanceRatePercent.toStringAsFixed(1);
  }

  String getFormattedAverageResponseTime() {
    if (averageResponseTimeHours == null) return '—';
    final hours = averageResponseTimeHours!;
    if (hours < 1) {
      return '${(hours * 60).round()} min';
    }
    if (hours < 24) {
      return '${hours.toStringAsFixed(1)} h';
    }
    return '${(hours / 24).toStringAsFixed(1)} j';
  }

  String getFormattedRevenue() {
    return '${totalRevenueCompleted.toStringAsFixed(0)} XOF';
  }

  String getFormattedAverageRating() {
    return averageRating.toStringAsFixed(1);
  }
}