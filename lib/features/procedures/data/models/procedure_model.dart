class ProcedureModel {
  final String id;
  final String title;
  final String description;
  final int estimatedCost;
  final int estimatedDurationDays;
  final String category;
  final int userProgress;

  ProcedureModel({required this.id, required this.title, required this.description, required this.estimatedCost, required this.estimatedDurationDays, required this.category, required this.userProgress});

  factory ProcedureModel.fromJson(Map<String, dynamic> json) => ProcedureModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        estimatedCost: json['estimatedCost'] as int,
        estimatedDurationDays: json['estimatedDurationDays'] as int,
        category: json['category'] as String,
        userProgress: json['userProgress'] as int,
      );
}
