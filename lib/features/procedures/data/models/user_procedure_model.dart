enum UserProcedureStatus { notStarted, inProgress, completed, skipped }

class UserProcedureModel {
  final String id;
  final String profileId;
  final String procedureId;
  final String? procedureTitle;
  final num? costAmount;
  final String? costCurrency;
  final UserProcedureStatus status;
  final String? completedByUserId;
  final String? completedByRole;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;

  UserProcedureModel({
    required this.id,
    required this.profileId,
    required this.procedureId,
    this.procedureTitle,
    this.costAmount,
    this.costCurrency,
    this.status = UserProcedureStatus.notStarted,
    this.completedByUserId,
    this.completedByRole,
    this.completedAt,
    this.notes,
    required this.createdAt,
  });

  factory UserProcedureModel.fromJson(Map<String, dynamic> json) {
    return UserProcedureModel(
      id: (json['Id'] ?? json['id'] ?? '') as String,
      profileId: (json['ProfileId'] ?? json['profileId'] ?? '') as String,
      procedureId: (json['ProcedureId'] ?? json['procedureId'] ?? '') as String,
      procedureTitle: (json['ProcedureTitle'] ?? json['procedureTitle']) as String?,
      costAmount: (json['CostAmount'] ?? json['costAmount']) as num?,
      costCurrency: (json['CostCurrency'] ?? json['costCurrency']) as String?,
      status: _parseStatus(json['Status'] ?? json['status'] ?? 0),
      completedByUserId: (json['CompletedByUserId'] ?? json['completedByUserId']) as String?,
      completedByRole: (json['CompletedByRole'] ?? json['completedByRole']) as String?,
      completedAt: _parseDateTime(json, 'CompletedAt', 'completedAt'),
      notes: (json['Notes'] ?? json['notes']) as String?,
      createdAt: _parseDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
    );
  }

  static UserProcedureStatus _parseStatus(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 0: return UserProcedureStatus.notStarted;
        case 1: return UserProcedureStatus.inProgress;
        case 2: return UserProcedureStatus.completed;
        case 3: return UserProcedureStatus.skipped;
      }
    }
    if (raw is String) {
      switch (raw.toLowerCase()) {
        case 'notstarted':
        case 'not_started':
          return UserProcedureStatus.notStarted;
        case 'inprogress':
        case 'in_progress':
          return UserProcedureStatus.inProgress;
        case 'completed':
          return UserProcedureStatus.completed;
        case 'skipped':
          return UserProcedureStatus.skipped;
      }
    }
    return UserProcedureStatus.notStarted;
  }

  static DateTime? _parseDateTime(Map<String, dynamic> json, String pascalKey, String camelKey) {
    final raw = json[pascalKey] ?? json[camelKey];
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}