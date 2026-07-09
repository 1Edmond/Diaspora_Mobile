class StepModel {
  final String id;
  final String title;
  final String description;
  final String? comment;
  final String? price;
  final String? address;
  final bool isCompleted;

  StepModel({
    required this.id,
    required this.title,
    required this.description,
    this.comment,
    this.price,
    this.address,
    this.isCompleted = false,
  });

  StepModel copyWith({bool? isCompleted}) {
    return StepModel(
      id: id,
      title: title,
      description: description,
      comment: comment,
      price: price,
      address: address,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory StepModel.fromJson(Map<String, dynamic> json) => StepModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        comment: json['comment'] as String?,
        price: json['price']?.toString(),
        address: json['address'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'comment': comment,
        'price': price?.toString(),
        'address': address,
        'isCompleted': isCompleted,
      };
}
