import '../../domain/entities/committee_member.dart';

class CommitteeMemberModel extends CommitteeMember {
  CommitteeMemberModel({
    required super.id,
    required super.userId,
    required super.committeeId,
    required super.role,
    required super.joinedAt,
    required super.status,
  });

  factory CommitteeMemberModel.fromJson(Map<String, dynamic> json) =>
      CommitteeMemberModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        committeeId: json['committeeId'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'committeeId': committeeId,
    'role': role,
    'joinedAt': joinedAt.toIso8601String(),
    'status': status,
  };
}
