import 'step_model.dart';

class ProcedureModel {
  final String id;
  final String title;
  final String description;
  final int estimatedCost;
  final int estimatedDurationDays;
  final String category;
  final int userProgress;
  final DateTime? deadline;
  final List<StepModel> steps;

  ProcedureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedCost,
    required this.estimatedDurationDays,
    required this.category,
    required this.userProgress,
    this.deadline,
    this.steps = const [],
  });

  ProcedureModel copyWith({int? userProgress, List<StepModel>? steps}) {
    return ProcedureModel(
      id: id,
      title: title,
      description: description,
      estimatedCost: estimatedCost,
      estimatedDurationDays: estimatedDurationDays,
      category: category,
      userProgress: userProgress ?? this.userProgress,
      deadline: deadline,
      steps: steps ?? this.steps,
    );
  }

  factory ProcedureModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>?;
    return ProcedureModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedCost: json['estimatedCost'] as int,
      estimatedDurationDays: json['estimatedDurationDays'] as int,
      category: json['category'] as String,
      userProgress: json['userProgress'] as int,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      steps: stepsJson != null ? stepsJson.map((e) => StepModel.fromJson(e as Map<String, dynamic>)).toList() : [],
    );
  }
}
