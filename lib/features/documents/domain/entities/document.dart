import 'document_category.dart';
import 'document_metadata.dart';

class Document {
  final String id;
  final String userId;
  final String title;
  final DocumentCategory category;
  final String? description;
  final String url;
  final int fileSizeBytes;
  final String mimeType;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final String? extractedText;
  final bool isVerified;
  final DocumentMetadata? metadata;

  Document({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.description,
    required this.url,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedAt,
    this.expiresAt,
    this.extractedText,
    this.isVerified = false,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      category: DocumentCategory.fromString(
        json['category'] as String? ?? 'OTHER',
      ),
      description: json['description'] as String?,
      url: json['url'] as String? ?? json['filePath'] as String? ?? '',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      uploadedAt: DateTime.parse(
        json['uploadedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      extractedText: json['extractedText'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      metadata:
          json['metadata'] != null
              ? DocumentMetadata.fromJson(
                json['metadata'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.value,
      'description': description,
      'url': url,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'extractedText': extractedText,
      'isVerified': isVerified,
      'metadata': metadata?.toJson(),
    };
  }

  Document copyWith({
    String? id,
    String? userId,
    String? title,
    DocumentCategory? category,
    String? description,
    String? url,
    int? fileSizeBytes,
    String? mimeType,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    String? extractedText,
    bool? isVerified,
    DocumentMetadata? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      url: url ?? this.url,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      extractedText: extractedText ?? this.extractedText,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get expiresInDays {
    if (expiresAt == null) return -1;
    final difference = expiresAt!.difference(DateTime.now());
    return difference.inDays;
  }

  String get formattedFileSize {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var bytes = fileSizeBytes.toDouble();
    var suffixIndex = 0;

    while (bytes >= 1024 && suffixIndex < suffixes.length - 1) {
      bytes /= 1024;
      suffixIndex++;
    }

    return '${bytes.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  bool get isPdf =>
      mimeType.contains('pdf') || url.toLowerCase().endsWith('.pdf');
  bool get isImage => mimeType.startsWith('image/');
}
