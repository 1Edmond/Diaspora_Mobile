class Committee {
  final String id;
  final String name;
  final String description;
  final String purpose;
  final List<String> memberIds;
  final String chairpersonId;
  final DateTime createdAt;
  final String status; // ACTIVE, INACTIVE, DISSOLVED

  Committee({
    required this.id,
    required this.name,
    required this.description,
    required this.purpose,
    required this.memberIds,
    required this.chairpersonId,
    required this.createdAt,
    required this.status,
  });
}
