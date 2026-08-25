import '../../domain/entities/enums.dart';

class ReportModel {
  final String id;
  final ReportTargetType targetType;
  final String targetId;
  final String reporterId;
  final String reason;
  final ReportStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolutionNotes;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reporterId,
    required this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNotes,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: _str(json, 'Id', 'id'),
      targetType: ReportTargetType.values[_int(json, 'TargetType', 'targetType')],
      targetId: _str(json, 'TargetId', 'targetId'),
      reporterId: _str(json, 'ReporterId', 'reporterId'),
      reason: _str(json, 'Reason', 'reason'),
      status: ReportStatus.values[_int(json, 'Status', 'status')],
      reviewedBy: _strOrNull(json, 'ReviewedBy', 'reviewedBy'),
      reviewedAt: _parseDateTime(json, 'ReviewedAt', 'reviewedAt'),
      resolutionNotes: _strOrNull(json, 'ResolutionNotes', 'resolutionNotes'),
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
    );
  }

  static String _str(Map<String, dynamic> json, String pascal, String camel) {
    return (json[pascal] ?? json[camel] ?? '') as String;
  }

  static String? _strOrNull(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return null;
    return val as String;
  }

  static int _int(Map<String, dynamic> json, String pascal, String camel) {
    final val = json[pascal] ?? json[camel];
    if (val == null) return 0;
    return (val as num).toInt();
  }

  static DateTime? _parseDateTime(Map<String, dynamic> json, String pascal, String camel) {
    final raw = json[pascal] ?? json[camel];
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'Id': id,
    'TargetType': targetType.index,
    'TargetId': targetId,
    'ReporterId': reporterId,
    'Reason': reason,
    'Status': status.index,
    'ReviewedBy': reviewedBy,
    'ReviewedAt': reviewedAt?.toIso8601String(),
    'ResolutionNotes': resolutionNotes,
    'CreatedAt': createdAt.toIso8601String(),
  };
}