import '../../domain/entities/enums.dart';
import 'json_helpers.dart';

class JobApplicationModel {
  final String id;
  final String jobPostingId;
  final String jobPostingTitle;
  final String workerId;
  final String workerName;
  final String? message;
  final JobApplicationStatus status;
  final DateTime? decidedAt;
  final String? decidedBy;
  final String? rejectionReason;
  final String? chatThreadId;
  final String? escrowTransactionId;
  final DateTime createdAt;

  const JobApplicationModel({
    required this.id,
    required this.jobPostingId,
    required this.jobPostingTitle,
    required this.workerId,
    required this.workerName,
    this.message,
    required this.status,
    this.decidedAt,
    this.decidedBy,
    this.rejectionReason,
    this.chatThreadId,
    this.escrowTransactionId,
    required this.createdAt,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: jstr(json, 'Id', 'id'),
      jobPostingId: jstr(json, 'JobPostingId', 'jobPostingId'),
      jobPostingTitle: jstr(json, 'JobPostingTitle', 'jobPostingTitle'),
      workerId: jstr(json, 'WorkerId', 'workerId'),
      workerName: jstr(json, 'WorkerName', 'workerName'),
      message: jstrOrNull(json, 'Message', 'message'),
      status: JobApplicationStatus.values[jint(json, 'Status', 'status').clamp(0, JobApplicationStatus.values.length - 1)],
      decidedAt: jDateTime(json, 'DecidedAt', 'decidedAt'),
      decidedBy: jstrOrNull(json, 'DecidedBy', 'decidedBy'),
      rejectionReason: jstrOrNull(json, 'RejectionReason', 'rejectionReason'),
      chatThreadId: jstrOrNull(json, 'ChatThreadId', 'chatThreadId'),
      escrowTransactionId: jstrOrNull(json, 'EscrowTransactionId', 'escrowTransactionId'),
      createdAt: jDateTime(json, 'CreatedAt', 'createdAt') ?? DateTime.now(),
    );
  }
}

class JobCheckInModel {
  final String id;
  final String jobApplicationId;
  final String workerId;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final CheckInMethod method;
  final CheckInStatus status;

  const JobCheckInModel({
    required this.id,
    required this.jobApplicationId,
    required this.workerId,
    required this.checkInAt,
    this.checkOutAt,
    this.checkInLatitude,
    this.checkInLongitude,
    required this.method,
    required this.status,
  });

  factory JobCheckInModel.fromJson(Map<String, dynamic> json) {
    return JobCheckInModel(
      id: jstr(json, 'Id', 'id'),
      jobApplicationId: jstr(json, 'JobApplicationId', 'jobApplicationId'),
      workerId: jstr(json, 'WorkerId', 'workerId'),
      checkInAt: jDateTime(json, 'CheckInAt', 'checkInAt') ?? DateTime.now(),
      checkOutAt: jDateTime(json, 'CheckOutAt', 'checkOutAt'),
      checkInLatitude: jdoubleOrNull(json, 'CheckInLatitude', 'checkInLatitude'),
      checkInLongitude: jdoubleOrNull(json, 'CheckInLongitude', 'checkInLongitude'),
      method: CheckInMethod.values[jint(json, 'Method', 'method').clamp(0, CheckInMethod.values.length - 1)],
      status: CheckInStatus.values[jint(json, 'Status', 'status').clamp(0, CheckInStatus.values.length - 1)],
    );
  }
}

class ReputationModel {
  final String subjectId;
  final ReputationRole role;
  final double averageRating;
  final double averagePunctuality;
  final double averageQuality;
  final double averageCommunication;
  final int totalRatings;
  final int totalJobsCompleted;

  const ReputationModel({
    required this.subjectId,
    required this.role,
    required this.averageRating,
    required this.averagePunctuality,
    required this.averageQuality,
    required this.averageCommunication,
    required this.totalRatings,
    required this.totalJobsCompleted,
  });

  bool get hasReviews => totalRatings > 0;

  factory ReputationModel.fromJson(Map<String, dynamic> json) {
    return ReputationModel(
      subjectId: jstr(json, 'SubjectId', 'subjectId'),
      role: ReputationRole.values[jint(json, 'Role', 'role').clamp(0, ReputationRole.values.length - 1)],
      averageRating: jdouble(json, 'AverageRating', 'averageRating'),
      averagePunctuality: jdouble(json, 'AveragePunctuality', 'averagePunctuality'),
      averageQuality: jdouble(json, 'AverageQuality', 'averageQuality'),
      averageCommunication: jdouble(json, 'AverageCommunication', 'averageCommunication'),
      totalRatings: jint(json, 'TotalRatings', 'totalRatings'),
      totalJobsCompleted: jint(json, 'TotalJobsCompleted', 'totalJobsCompleted'),
    );
  }
}

class WorkerJobPreferenceModel {
  final String id;
  final String workerId;
  final String categoryId;
  final String? city;
  final double? maxDistanceKm;

  const WorkerJobPreferenceModel({
    required this.id,
    required this.workerId,
    required this.categoryId,
    this.city,
    this.maxDistanceKm,
  });

  factory WorkerJobPreferenceModel.fromJson(Map<String, dynamic> json) {
    return WorkerJobPreferenceModel(
      id: jstr(json, 'Id', 'id'),
      workerId: jstr(json, 'WorkerId', 'workerId'),
      categoryId: jstr(json, 'CategoryId', 'categoryId'),
      city: jstrOrNull(json, 'City', 'city'),
      maxDistanceKm: jdoubleOrNull(json, 'MaxDistanceKm', 'maxDistanceKm'),
    );
  }
}