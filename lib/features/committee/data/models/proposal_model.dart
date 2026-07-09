import '../../domain/entities/proposal.dart';

class ProposalModel extends Proposal {
  ProposalModel({
    required super.id,
    required super.committeeId,
    required super.title,
    required super.description,
    required super.proposerId,
    required super.submittedAt,
    required super.status,
    required super.votes,
    super.decision,
    super.decidedAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) => ProposalModel(
    id: json['id'] as String,
    committeeId: json['committeeId'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    proposerId: json['proposerId'] as String,
    submittedAt: DateTime.parse(json['submittedAt'] as String),
    status: json['status'] as String,
    votes: (json['votes'] as List).map((v) => VoteModel.fromJson(v)).toList(),
    decision: json['decision'] as String?,
    decidedAt:
        json['decidedAt'] != null
            ? DateTime.parse(json['decidedAt'] as String)
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'committeeId': committeeId,
    'title': title,
    'description': description,
    'proposerId': proposerId,
    'submittedAt': submittedAt.toIso8601String(),
    'status': status,
    'votes': votes.map((v) => (v as VoteModel).toJson()).toList(),
    'decision': decision,
    'decidedAt': decidedAt?.toIso8601String(),
  };
}

class VoteModel extends Vote {
  VoteModel({
    required super.id,
    required super.proposalId,
    required super.voterId,
    required super.vote,
    required super.votedAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
    id: json['id'] as String,
    proposalId: json['proposalId'] as String,
    voterId: json['voterId'] as String,
    vote: json['vote'] as String,
    votedAt: DateTime.parse(json['votedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'proposalId': proposalId,
    'voterId': voterId,
    'vote': vote,
    'votedAt': votedAt.toIso8601String(),
  };
}
