class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final String target;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    required this.target,
    this.data,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
    String? target,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      target: target ?? this.target,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'read': isRead,
      'target': target,
      'data': data,
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['imageUrl'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['read'] as bool? ?? false,
      target: map['target'] as String,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}
