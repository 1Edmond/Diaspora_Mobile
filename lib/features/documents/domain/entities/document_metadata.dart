import 'document_category.dart';

class DocumentMetadata {
  final String id;
  final String userId;
  final String title;
  final DocumentCategory category;
  final String? description;
  final int fileSizeBytes;
  final String mimeType;
  final String filePath;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final String? extractedText;
  final bool isVerified;

  DocumentMetadata({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.description,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.filePath,
    required this.uploadedAt,
    this.expiresAt,
    this.extractedText,
    this.isVerified = false,
  });

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      category: DocumentCategory.fromString(
        json['category'] as String? ?? 'OTHER',
      ),
      description: json['description'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      filePath: json['filePath'] as String,
      uploadedAt: DateTime.parse(
        json['uploadedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      expiresAt:
          json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      extractedText: json['extractedText'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'category': category.value,
      'description': description,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'filePath': filePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'extractedText': extractedText,
      'isVerified': isVerified,
    };
  }

  DocumentMetadata copyWith({
    String? id,
    String? userId,
    String? title,
    DocumentCategory? category,
    String? description,
    int? fileSizeBytes,
    String? mimeType,
    String? filePath,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    String? extractedText,
    bool? isVerified,
  }) {
    return DocumentMetadata(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      filePath: filePath ?? this.filePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      extractedText: extractedText ?? this.extractedText,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
