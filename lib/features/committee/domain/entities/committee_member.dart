class CommitteeMember {
  final String id;
  final String userId;
  final String committeeId;
  final String role; // CHAIRPERSON, SECRETARY, MEMBER
  final DateTime joinedAt;
  final String status; // ACTIVE, INACTIVE

  CommitteeMember({
    required this.id,
    required this.userId,
    required this.committeeId,
    required this.role,
    required this.joinedAt,
    required this.status,
  });
}
