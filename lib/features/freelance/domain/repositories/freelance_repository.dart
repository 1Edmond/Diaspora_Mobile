import '../../../marketplace/data/models/paged_result.dart';
import '../../data/models/job_category_model.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/job_application_model.dart';
import '../../data/models/freelance_dtos.dart';

abstract class IFreelanceRepository {
  // Categories
  Future<List<JobCategoryModel>> getCategories();

  // Templates (employer)
  Future<JobTemplateModel> createTemplate(CreateJobTemplateDto dto);
  Future<JobTemplateModel> updateTemplate(String id, CreateJobTemplateDto dto);
  Future<void> deleteTemplate(String id);
  Future<List<JobTemplateModel>> getMyTemplates();

  // Job postings
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
  });

  Future<JobPostingModel> getJobPosting(String id);

  Future<PagedResult<JobPostingSummaryModel>> getMyJobPostings({
    int page = 1,
    int pageSize = 20,
  });

  Future<JobPostingModel> createJobPosting(CreateJobPostingDto dto);

  Future<JobPostingModel> updateJobPosting(String id, UpdateJobPostingDto dto);

  Future<void> deleteJobPosting(String id);

  Future<void> publishJobPosting(String id);

  Future<void> closeRegistration(String id);

  Future<void> startJobPosting(String id);

  Future<void> completeJobPosting(String id);

  Future<void> cancelJobPosting(String id, String? reason);

  // Applications
  Future<JobApplicationModel> applyToJob(
    String jobPostingId,
    String? message,
  );

  Future<void> withdrawApplication(String id);

  Future<void> acceptApplication(String id, {String? escrowTransactionId});

  Future<void> rejectApplication(String id, {String? reason});

  Future<void> noShowApplication(String id);

  Future<void> completeApplication(String id);

  Future<void> linkApplicationChatThread(String id, String chatThreadId);

  Future<PagedResult<JobApplicationModel>> getMyApplications({
    int page = 1,
    int pageSize = 20,
  });

  Future<PagedResult<JobApplicationModel>> getJobPostingApplications(
    String jobPostingId, {
    int page = 1,
    int pageSize = 20,
  });

  Future<JobApplicationModel> getApplication(String id);

  // Check-ins
  Future<JobCheckInModel> createCheckIn(
    String applicationId,
    CreateJobCheckInDto dto,
  );

  Future<void> checkOut(String checkInId);

  Future<List<JobCheckInModel>> getApplicationCheckIns(String applicationId);

  // Reviews & reputation
  Future<void> createJobReview(String applicationId, CreateJobReviewDto dto);

  Future<ReputationModel> getReputation(String subjectId, int role);

  // Preferences (matching)
  Future<WorkerJobPreferenceModel> createJobPreference(
    CreateJobPreferenceDto dto,
  );

  Future<void> deleteJobPreference(String id);

  Future<List<WorkerJobPreferenceModel>> getMyJobPreferences();
}