import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../marketplace/data/models/paged_result.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../models/job_category_model.dart';
import '../models/job_posting_model.dart';
import '../models/job_application_model.dart';
import '../models/freelance_dtos.dart';
import '../../domain/repositories/freelance_repository.dart';

class FreelanceRepositoryImpl implements IFreelanceRepository {
  final DioClient _client;

  FreelanceRepositoryImpl({required DioClient client}) : _client = client;

  @override
  Future<List<JobCategoryModel>> getCategories() async {
    final res = await _client.get('/freelance/job-categories');
    if (res is List) {
      return res
          .map((e) => JobCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<JobTemplateModel> createTemplate(CreateJobTemplateDto dto) async {
    final res = await _client.post('/freelance/job-templates', data: dto.toJson());
    return JobTemplateModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobTemplateModel> updateTemplate(
    String id,
    CreateJobTemplateDto dto,
  ) async {
    final res = await _client.put('/freelance/job-templates/$id', data: dto.toJson());
    if (res is Map<String, dynamic> && res.isNotEmpty) {
      return JobTemplateModel.fromJson(res);
    }
    return JobTemplateModel.fromJson({'id': id, ...dto.toJson()});
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _client.delete('/freelance/job-templates/$id');
  }

  @override
  Future<List<JobTemplateModel>> getMyTemplates() async {
    final res = await _client.get('/freelance/job-templates');
    if (res is List) {
      return res
          .map((e) => JobTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res is Map<String, dynamic>) {
      final items = (res['items'] ?? res['Items']) as List<dynamic>?;
      if (items != null) {
        return items
            .map((e) => JobTemplateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<PagedResult<JobPostingSummaryModel>> getJobPostings({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? search,
    int? paymentType,
    double? minAmount,
    double? maxAmount,
    String? city,
    String? country,
    bool? isRemote,
    String? eventStartsAfter,
    String? eventStartsBefore,
    double? userLatitude,
    double? userLongitude,
    double? maxDistanceKm,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (paymentType != null) queryParams['paymentType'] = paymentType;
    if (minAmount != null) queryParams['minAmount'] = minAmount;
    if (maxAmount != null) queryParams['maxAmount'] = maxAmount;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (country != null && country.isNotEmpty) {
      queryParams['country'] = country;
    }
    if (isRemote != null) queryParams['isRemote'] = isRemote;
    if (eventStartsAfter != null) {
      queryParams['eventStartsAfter'] = eventStartsAfter;
    }
    if (eventStartsBefore != null) {
      queryParams['eventStartsBefore'] = eventStartsBefore;
    }
    if (userLatitude != null) queryParams['userLatitude'] = userLatitude;
    if (userLongitude != null) queryParams['userLongitude'] = userLongitude;
    if (maxDistanceKm != null) queryParams['maxDistanceKm'] = maxDistanceKm;

    final res = await _client.get(
      '/freelance/job-postings',
      queryParameters: queryParams,
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobPostingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<JobPostingModel> getJobPosting(String id) async {
    final res = await _client.get('/freelance/job-postings/$id');
    return JobPostingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<JobPostingSummaryModel>> getMyJobPostings({
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get(
      '/freelance/job-postings/my',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobPostingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<JobPostingModel> createJobPosting(CreateJobPostingDto dto) async {
    final res = await _client.post('/freelance/job-postings', data: dto.toJson());
    return JobPostingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobPostingModel> updateJobPosting(
    String id,
    UpdateJobPostingDto dto,
  ) async {
    final res = await _client.put('/freelance/job-postings/$id', data: dto.toJson());
    if (res is Map<String, dynamic> && res.isNotEmpty) {
      return JobPostingModel.fromJson(res);
    }
    return getJobPosting(id);
  }

  @override
  Future<void> deleteJobPosting(String id) async {
    await _client.delete('/freelance/job-postings/$id');
  }

  @override
  Future<void> publishJobPosting(String id) async {
    await _client.post('/freelance/job-postings/$id/publish');
  }

  @override
  Future<void> closeRegistration(String id) async {
    await _client.post('/freelance/job-postings/$id/close-registration');
  }

  @override
  Future<void> startJobPosting(String id) async {
    await _client.post('/freelance/job-postings/$id/start');
  }

  @override
  Future<void> completeJobPosting(String id) async {
    await _client.post('/freelance/job-postings/$id/complete');
  }

  @override
  Future<void> cancelJobPosting(String id, String? reason) async {
    await _client.post('/freelance/job-postings/$id/cancel', data: {'reason': reason});
  }

  @override
  Future<JobApplicationModel> applyToJob(
    String jobPostingId,
    String? message,
  ) async {
    final res = await _client.post(
      '/freelance/job-applications',
      data: {
        'jobPostingId': jobPostingId,
        'JobPostingId': jobPostingId,
        'message': message,
        'coverLetter': message,
      },
    );
    return JobApplicationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> withdrawApplication(String id) async {
    await _client.post('/freelance/job-applications/$id/withdraw');
  }

  @override
  Future<void> acceptApplication(
    String id, {
    String? escrowTransactionId,
  }) async {
    await _client.post('/freelance/job-applications/$id/accept', data: {
      'escrowTransactionId': escrowTransactionId,
    });
  }

  @override
  Future<void> rejectApplication(String id, {String? reason}) async {
    await _client.post('/freelance/job-applications/$id/reject', data: {'reason': reason});
  }

  @override
  Future<void> noShowApplication(String id) async {
    await _client.post('/freelance/job-applications/$id/no-show');
  }

  @override
  Future<void> completeApplication(String id) async {
    await _client.post('/freelance/job-applications/$id/complete');
  }

  @override
  Future<void> linkApplicationChatThread(
    String id,
    String chatThreadId,
  ) async {
    await _client.post('/freelance/job-applications/$id/chat-thread', data: {
      'chatThreadId': chatThreadId,
    });
  }

  @override
  Future<PagedResult<JobApplicationModel>> getMyApplications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get(
      '/freelance/job-applications/sent',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobApplicationModel.fromJson(json),
    );
  }

  @override
  Future<PagedResult<JobApplicationModel>> getJobPostingApplications(
    String jobPostingId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final path = AppConfig.useMockData
        ? '/freelance/job-postings/$jobPostingId/applications'
        : '/freelance/job-applications/received';
    final res = await _client.get(
      path,
      queryParameters: {
        'jobPostingId': jobPostingId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobApplicationModel.fromJson(json),
    );
  }

  @override
  Future<JobApplicationModel> getApplication(String id) async {
    final res = await _client.get('/freelance/job-applications/$id');
    return JobApplicationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobCheckInModel> createCheckIn(
    String applicationId,
    CreateJobCheckInDto dto,
  ) async {
    final res = await _client.post(
      '/freelance/job-check-ins/check-in',
      data: {
        ...dto.toJson(),
        'jobApplicationId': applicationId,
        'JobApplicationId': applicationId,
      },
    );
    return JobCheckInModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> checkOut(String checkInId) async {
    await _client.post(
      '/freelance/job-check-ins/check-out',
      data: {
        'checkInId': checkInId,
        'jobApplicationId': checkInId,
        'JobApplicationId': checkInId,
      },
    );
  }

  @override
  Future<List<JobCheckInModel>> getApplicationCheckIns(
    String applicationId,
  ) async {
    final res = await _client.get(
      '/freelance/job-check-ins',
      queryParameters: {'applicationId': applicationId},
    );
    if (res is List) {
      return res
          .map((e) => JobCheckInModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res is Map<String, dynamic>) {
      final items = (res['items'] ?? res['Items']) as List<dynamic>?;
      if (items != null) {
        return items
            .map((e) => JobCheckInModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<void> createJobReview(
    String applicationId,
    CreateJobReviewDto dto,
  ) async {
    await _client.post(
      '/freelance/job-reviews',
      data: {
        ...dto.toJson(),
        'jobApplicationId': applicationId,
        'JobApplicationId': applicationId,
      },
    );
  }

  @override
  Future<ReputationModel> getReputation(String subjectId, int role) async {
    final res = await _client.get(
      '/freelance/reputation/$subjectId',
      queryParameters: {'role': role},
    );
    return ReputationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<WorkerJobPreferenceModel> createJobPreference(
    CreateJobPreferenceDto dto,
  ) async {
    final res = AppConfig.useMockData
        ? await _client.post('/freelance/worker-preferences', data: dto.toJson())
        : await _client.put('/freelance/worker-preferences', data: dto.toJson());
    if (res is Map<String, dynamic> && res.isNotEmpty) {
      return WorkerJobPreferenceModel.fromJson(res);
    }
    return WorkerJobPreferenceModel.fromJson(dto.toJson());
  }

  @override
  Future<void> deleteJobPreference(String id) async {
    final path = AppConfig.useMockData
        ? '/freelance/worker-preferences/$id'
        : '/freelance/worker-preferences';
    await _client.delete(path);
  }

  @override
  Future<List<WorkerJobPreferenceModel>> getMyJobPreferences() async {
    final res = await _client.get('/freelance/worker-preferences');
    if (res is List) {
      return res
          .map((e) => WorkerJobPreferenceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res is Map<String, dynamic> && res.isNotEmpty) {
      return [WorkerJobPreferenceModel.fromJson(res)];
    }
    return [];
  }
}

final freelanceRepositoryProvider = Provider<IFreelanceRepository>((ref) {
  return GetIt.instance<IFreelanceRepository>();
});