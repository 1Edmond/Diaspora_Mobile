class Proposal {
  final String id;
  final String committeeId;
  final String title;
  final String description;
  final String proposerId;
  final DateTime submittedAt;
  final String status; // PENDING, UNDER_REVIEW, APPROVED, REJECTED, IMPLEMENTED
  final List<Vote> votes;
  final String? decision;
  final DateTime? decidedAt;

  Proposal({
    required this.id,
    required this.committeeId,
    required this.title,
    required this.description,
    required this.proposerId,
    required this.submittedAt,
    required this.status,
    required this.votes,
    this.decision,
    this.decidedAt,
  });
}

class Vote {
  final String id;
  final String proposalId;
  final String voterId;
  final String vote; // YES, NO, ABSTAIN
  final DateTime votedAt;

  Vote({
    required this.id,
    required this.proposalId,
    required this.voterId,
    required this.vote,
    required this.votedAt,
  });
}
