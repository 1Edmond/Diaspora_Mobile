import '../../domain/entities/committee.dart';

class CommitteeModel extends Committee {
  CommitteeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.purpose,
    required super.memberIds,
    required super.chairpersonId,
    required super.createdAt,
    required super.status,
  });

  factory CommitteeModel.fromJson(Map<String, dynamic> json) => CommitteeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    purpose: json['purpose'] as String,
    memberIds: List<String>.from(json['memberIds'] as List),
    chairpersonId: json['chairpersonId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'purpose': purpose,
    'memberIds': memberIds,
    'chairpersonId': chairpersonId,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };
}
