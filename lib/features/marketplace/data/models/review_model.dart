class ReviewModel {
  final String id;
  final String listingId;
  final String reviewerId;
  final String reviewerName;
  final int rating;
  final String comment;
  final bool isVerified;
  final DateTime createdAt;
  final String? providerReply;
  final DateTime? providerRepliedAt;

  const ReviewModel({
    required this.id,
    required this.listingId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.isVerified,
    required this.createdAt,
    this.providerReply,
    this.providerRepliedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _str(json, 'Id', 'id'),
      listingId: _str(json, 'ListingId', 'listingId'),
      reviewerId: _str(json, 'ReviewerId', 'reviewerId'),
      reviewerName: _str(json, 'ReviewerName', 'reviewerName'),
      rating: _int(json, 'Rating', 'rating'),
      comment: _str(json, 'Comment', 'comment'),
      isVerified: _bool(json, 'IsVerified', 'isVerified'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      providerReply: _strOrNull(json, 'ProviderReply', 'providerReply'),
      providerRepliedAt: _parseDateTime(json, 'ProviderRepliedAt', 'providerRepliedAt'),
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

  static bool _bool(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return false;
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return val == 1;
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
    'ReviewerId': reviewerId,
    'ReviewerName': reviewerName,
    'Rating': rating,
    'Comment': comment,
    'IsVerified': isVerified,
    'CreatedAt': createdAt.toIso8601String(),
    'ProviderReply': providerReply,
    'ProviderRepliedAt': providerRepliedAt?.toIso8601String(),
  };
}