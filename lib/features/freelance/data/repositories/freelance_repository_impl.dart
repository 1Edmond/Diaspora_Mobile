import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../../marketplace/data/models/paged_result.dart';
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
    final res = await _client.get('/job-categories');
    if (res is List) {
      return res
          .map((e) => JobCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<JobTemplateModel> createTemplate(CreateJobTemplateDto dto) async {
    final res = await _client.post('/job-templates', data: dto.toJson());
    return JobTemplateModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobTemplateModel> updateTemplate(
    String id,
    CreateJobTemplateDto dto,
  ) async {
    final res = await _client.put('/job-templates/$id', data: dto.toJson());
    return JobTemplateModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _client.delete('/job-templates/$id');
  }

  @override
  Future<List<JobTemplateModel>> getMyTemplates() async {
    final res = await _client.get('/job-templates/my');
    if (res is List) {
      return res
          .map((e) => JobTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
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

    final res = await _client.get('/job-postings', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobPostingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<JobPostingModel> getJobPosting(String id) async {
    final res = await _client.get('/job-postings/$id');
    return JobPostingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<JobPostingSummaryModel>> getMyJobPostings({
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get(
      '/job-postings/my',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobPostingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<JobPostingModel> createJobPosting(CreateJobPostingDto dto) async {
    final res = await _client.post('/job-postings', data: dto.toJson());
    return JobPostingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobPostingModel> updateJobPosting(
    String id,
    UpdateJobPostingDto dto,
  ) async {
    final res = await _client.put('/job-postings/$id', data: dto.toJson());
    return JobPostingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteJobPosting(String id) async {
    await _client.delete('/job-postings/$id');
  }

  @override
  Future<void> publishJobPosting(String id) async {
    await _client.post('/job-postings/$id/publish');
  }

  @override
  Future<void> closeRegistration(String id) async {
    await _client.post('/job-postings/$id/close-registration');
  }

  @override
  Future<void> startJobPosting(String id) async {
    await _client.post('/job-postings/$id/start');
  }

  @override
  Future<void> completeJobPosting(String id) async {
    await _client.post('/job-postings/$id/complete');
  }

  @override
  Future<void> cancelJobPosting(String id, String? reason) async {
    await _client.post('/job-postings/$id/cancel', data: {'reason': reason});
  }

  @override
  Future<JobApplicationModel> applyToJob(
    String jobPostingId,
    String? message,
  ) async {
    final res = await _client.post(
      '/job-postings/$jobPostingId/applications',
      data: {'message': message},
    );
    return JobApplicationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> withdrawApplication(String id) async {
    await _client.post('/applications/$id/withdraw');
  }

  @override
  Future<void> acceptApplication(
    String id, {
    String? escrowTransactionId,
  }) async {
    await _client.post('/applications/$id/accept', data: {
      'escrowTransactionId': escrowTransactionId,
    });
  }

  @override
  Future<void> rejectApplication(String id, {String? reason}) async {
    await _client.post('/applications/$id/reject', data: {'reason': reason});
  }

  @override
  Future<void> noShowApplication(String id) async {
    await _client.post('/applications/$id/no-show');
  }

  @override
  Future<void> completeApplication(String id) async {
    await _client.post('/applications/$id/complete');
  }

  @override
  Future<void> linkApplicationChatThread(
    String id,
    String chatThreadId,
  ) async {
    await _client.post('/applications/$id/chat-thread', data: {
      'chatThreadId': chatThreadId,
    });
  }

  @override
  Future<PagedResult<JobApplicationModel>> getMyApplications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.get(
      '/applications/my',
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
    final res = await _client.get(
      '/job-postings/$jobPostingId/applications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => JobApplicationModel.fromJson(json),
    );
  }

  @override
  Future<JobApplicationModel> getApplication(String id) async {
    final res = await _client.get('/applications/$id');
    return JobApplicationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<JobCheckInModel> createCheckIn(
    String applicationId,
    CreateJobCheckInDto dto,
  ) async {
    final res = await _client.post(
      '/applications/$applicationId/check-ins',
      data: dto.toJson(),
    );
    return JobCheckInModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> checkOut(String checkInId) async {
    await _client.post('/check-ins/$checkInId/check-out');
  }

  @override
  Future<List<JobCheckInModel>> getApplicationCheckIns(
    String applicationId,
  ) async {
    final res = await _client.get('/applications/$applicationId/check-ins');
    if (res is List) {
      return res
          .map((e) => JobCheckInModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> createJobReview(
    String applicationId,
    CreateJobReviewDto dto,
  ) async {
    await _client.post('/applications/$applicationId/reviews', data: dto.toJson());
  }

  @override
  Future<ReputationModel> getReputation(String subjectId, int role) async {
    final res = await _client.get(
      '/reputation/$subjectId',
      queryParameters: {'role': role},
    );
    return ReputationModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<WorkerJobPreferenceModel> createJobPreference(
    CreateJobPreferenceDto dto,
  ) async {
    final res = await _client.post('/job-preferences', data: dto.toJson());
    return WorkerJobPreferenceModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteJobPreference(String id) async {
    await _client.delete('/job-preferences/$id');
  }

  @override
  Future<List<WorkerJobPreferenceModel>> getMyJobPreferences() async {
    final res = await _client.get('/job-preferences/my');
    if (res is List) {
      return res
          .map((e) => WorkerJobPreferenceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

final freelanceRepositoryProvider = Provider<IFreelanceRepository>((ref) {
  return GetIt.instance<IFreelanceRepository>();
});