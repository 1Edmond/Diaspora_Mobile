import 'document_status.dart';

class DocumentDtoModel {
  final String id;
  final String profileId;
  final String documentTypeId;
  final String? documentTypeName;
  final String? documentTypeCode;
  final String? fileName;
  final int fileSize;
  final String? mimeType;
  final String? filePath;
  final DocumentStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? issuedAt;
  final String? issuedBy;
  final String? rejectionReason;
  final DateTime? validatedAt;
  final String? extractedText;

  DocumentDtoModel({
    required this.id,
    required this.profileId,
    required this.documentTypeId,
    this.documentTypeName,
    this.documentTypeCode,
    this.fileName,
    this.fileSize = 0,
    this.mimeType,
    this.filePath,
    this.status = DocumentStatus.pending,
    required this.createdAt,
    this.expiresAt,
    this.issuedAt,
    this.issuedBy,
    this.rejectionReason,
    this.validatedAt,
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
      documentTypeCode:
          (json['DocumentTypeCode'] ?? json['documentTypeCode']) as String?,
      fileName: (json['FileName'] ?? json['fileName']) as String?,
      fileSize: ((json['FileSize'] ?? json['fileSize'] ?? 0) as num).toInt(),
      mimeType: (json['MimeType'] ?? json['mimeType']) as String?,
      filePath: (json['FilePath'] ?? json['filePath']) as String?,
      status: DocumentStatus.fromValue(
        (json['Status'] ?? json['status'] ?? 0) as int,
      ),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
      expiresAt: _parseDateTime(json, 'ExpiresAt', 'expiresAt'),
      issuedAt: _parseDateTime(json, 'IssuedAt', 'issuedAt'),
      issuedBy: (json['IssuedBy'] ?? json['issuedBy']) as String?,
      rejectionReason:
          (json['RejectionReason'] ?? json['rejectionReason']) as String?,
      validatedAt: _parseDateTime(json, 'ValidatedAt', 'validatedAt'),
      extractedText: (json['ExtractedText'] ?? json['extractedText']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ProfileId': profileId,
    'DocumentTypeId': documentTypeId,
    'DocumentTypeName': documentTypeName,
    'DocumentTypeCode': documentTypeCode,
    'FileName': fileName,
    'FileSize': fileSize,
    'MimeType': mimeType,
    'FilePath': filePath,
    'Status': status.value,
    'CreatedAt': createdAt.toIso8601String(),
    'ExpiresAt': expiresAt?.toIso8601String(),
    'IssuedAt': issuedAt?.toIso8601String(),
    'IssuedBy': issuedBy,
    'RejectionReason': rejectionReason,
    'ValidatedAt': validatedAt?.toIso8601String(),
  };

  String get formattedFileSize {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var bytes = fileSize.toDouble();
    var suffixIndex = 0;
    while (bytes >= 1024 && suffixIndex < suffixes.length - 1) {
      bytes /= 1024;
      suffixIndex++;
    }
    return '${bytes.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }

  String get formattedMimeType {
    if (mimeType == null) return '';
    return _formatMimeType(mimeType!);
  }

  static String _formatMimeType(String raw) {
    final sub = raw.split('/').last; // "application/pdf" → "pdf"
    if (sub.isEmpty) return raw.toUpperCase();
    return sub.toUpperCase();
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
      (filePath?.toLowerCase().endsWith('.pdf') ?? false);

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