class ProviderStatsModel {
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

  const ProviderStatsModel({
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

  factory ProviderStatsModel.fromJson(Map<String, dynamic> json) {
    return ProviderStatsModel(
      totalListings: _int(json, 'TotalListings', 'totalListings'),
      activeListings: _int(json, 'ActiveListings', 'activeListings'),
      totalRequestsReceived: _int(json, 'TotalRequestsReceived', 'totalRequestsReceived'),
      acceptedRequests: _int(json, 'AcceptedRequests', 'acceptedRequests'),
      completedRequests: _int(json, 'CompletedRequests', 'completedRequests'),
      acceptanceRatePercent: _double(json, 'AcceptanceRatePercent', 'acceptanceRatePercent'),
      averageResponseTimeHours: _double(json, 'AverageResponseTimeHours', 'averageResponseTimeHours'),
      totalRevenueCompleted: _double(json, 'TotalRevenueCompleted', 'totalRevenueCompleted'),
      averageRating: _double(json, 'AverageRating', 'averageRating'),
      totalReviews: _int(json, 'TotalReviews', 'totalReviews'),
      totalFavorites: _int(json, 'TotalFavorites', 'totalFavorites'),
    );
  }

  static int _int(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0;
    return (val as num).toInt();
  }

  static double _double(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }
}