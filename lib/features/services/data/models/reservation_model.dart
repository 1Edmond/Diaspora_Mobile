class ReservationModel {
  final String id;
  final String serviceId;
  final String userId;
  final String providerId;
  final String serviceTitle;
  final String status;
  final DateTime date;
  final double price;
  final String currency;
  final String? notes;
  final int? rating;
  final String? comment;

  ReservationModel({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.providerId,
    required this.serviceTitle,
    required this.status,
    required this.date,
    required this.price,
    required this.currency,
    this.notes,
    this.rating,
    this.comment,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      userId: json['userId'] as String,
      providerId: json['providerId'] as String,
      serviceTitle: json['serviceTitle'] as String,
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
    );
  }

  ReservationModel copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? providerId,
    String? serviceTitle,
    String? status,
    DateTime? date,
    double? price,
    String? currency,
    String? notes,
    int? rating,
    String? comment,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      status: status ?? this.status,
      date: date ?? this.date,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }
}
