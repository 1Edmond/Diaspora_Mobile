import 'document_status.dart';

class DocumentDtoModel {
  final String id;
  final String profileId;
  final String documentTypeId;
  final String? documentTypeName;
  final String? fileName;
  final String? fileUrl;
  final int fileSizeBytes;
  final String? mimeType;
  final DocumentStatus status;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final DateTime? issuedAt;
  final String? issuedBy;
  final bool isVerified;
  final String? extractedText;

  DocumentDtoModel({
    required this.id,
    required this.profileId,
    required this.documentTypeId,
    this.documentTypeName,
    this.fileName,
    this.fileUrl,
    this.fileSizeBytes = 0,
    this.mimeType,
    this.status = DocumentStatus.pending,
    required this.uploadedAt,
    this.expiresAt,
    this.issuedAt,
    this.issuedBy,
    this.isVerified = false,
    this.extractedText,
  });

  factory DocumentDtoModel.fromJson(Map<String, dynamic> json) {
    return DocumentDtoModel(
      id: (json['Id'] ?? json['id'] ?? '') as String,
      profileId: (json['ProfileId'] ?? json['profileId'] ?? '') as String,
      documentTypeId:
          (json['DocumentTypeId'] ?? json['documentTypeId'] ?? '') as String,
      documentTypeName:
          (json['DocumentTypeName'] ?? json['documentTypeName']) as String?,
      fileName: (json['FileName'] ?? json['fileName']) as String?,
      fileUrl: (json['FileUrl'] ?? json['fileUrl']) as String?,
      fileSizeBytes:
          (json['FileSizeBytes'] ?? json['fileSizeBytes'] ?? 0) as int,
      mimeType: (json['MimeType'] ?? json['mimeType']) as String?,
      status: DocumentStatus.fromValue(
        (json['Status'] ?? json['status'] ?? 0) as int,
      ),
      uploadedAt: _parseDateTime(json, 'UploadedAt', 'uploadedAt') ?? DateTime.now(),
      expiresAt: _parseDateTime(json, 'ExpiresAt', 'expiresAt'),
      issuedAt: _parseDateTime(json, 'IssuedAt', 'issuedAt'),
      issuedBy: (json['IssuedBy'] ?? json['issuedBy']) as String?,
      isVerified: (json['IsVerified'] ?? json['isVerified'] ?? false) as bool,
      extractedText: (json['ExtractedText'] ?? json['extractedText']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'documentTypeId': documentTypeId,
    'documentTypeName': documentTypeName,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'fileSizeBytes': fileSizeBytes,
    'mimeType': mimeType,
    'status': status.value,
    'uploadedAt': uploadedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'issuedAt': issuedAt?.toIso8601String(),
    'issuedBy': issuedBy,
    'isVerified': isVerified,
    'extractedText': extractedText,
  };

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

  bool get isExpired {
    if (expiresAt == null) return false;
    if (status == DocumentStatus.expired) return true;
    return DateTime.now().isAfter(expiresAt!);
  }

  int get expiresInDays {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  bool get isPdf =>
      mimeType?.contains('pdf') == true ||
      (fileUrl?.toLowerCase().endsWith('.pdf') ?? false);

  bool get isImage => mimeType?.startsWith('image/') == true;

  static DateTime? _parseDateTime(
    Map<String, dynamic> json,
    String pascalKey,
    String camelKey,
  ) {
    final raw = json[pascalKey] ?? json[camelKey];
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}
