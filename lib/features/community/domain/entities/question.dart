class Question {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final List<String> tags;
  final int answers;
  final int views;
  final int upvotes;
  final bool isResolved;
  final String? bestAnswerId;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.tags = const [],
    this.answers = 0,
    this.views = 0,
    this.upvotes = 0,
    this.isResolved = false,
    this.bestAnswerId,
    required this.createdAt,
  });
}
