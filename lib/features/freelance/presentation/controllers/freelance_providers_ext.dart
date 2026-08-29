import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/job_application_model.dart';
import '../../data/models/job_category_model.dart';
import '../../domain/repositories/freelance_repository.dart';
import 'freelance_providers.dart';

// ==================== My job postings (employer) ====================
class MyJobPostingsState {
  final List<JobPostingSummaryModel> items;
  final bool isLoading;
  final String? error;

  const MyJobPostingsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MyJobPostingsState copyWith({
    List<JobPostingSummaryModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return MyJobPostingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MyJobPostingsNotifier extends StateNotifier<MyJobPostingsState> {
  final IFreelanceRepository _repository;
  MyJobPostingsNotifier(this._repository) : super(const MyJobPostingsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getMyJobPostings();
      state = state.copyWith(items: result.items, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> publish(String id) async {
    try {
      await _repository.publishJobPosting(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> closeRegistration(String id) async {
    try {
      await _repository.closeRegistration(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> start(String id) async {
    try {
      await _repository.startJobPosting(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> complete(String id) async {
    try {
      await _repository.completeJobPosting(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(String id) async {
    try {
      await _repository.cancelJobPosting(id, null);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final myJobPostingsProvider =
    StateNotifierProvider<MyJobPostingsNotifier, MyJobPostingsState>((ref) {
  return MyJobPostingsNotifier(ref.watch(freelanceRepositoryProvider));
});

// ==================== Applications for a job posting ====================
class JobApplicationsState {
  final List<JobApplicationModel> items;
  final bool isLoading;
  final String? error;

  const JobApplicationsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  JobApplicationsState copyWith({
    List<JobApplicationModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return JobApplicationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobApplicationsNotifier extends StateNotifier<JobApplicationsState> {
  final IFreelanceRepository _repository;
  JobApplicationsNotifier(this._repository) : super(const JobApplicationsState());

  Future<void> load(String jobPostingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getJobPostingApplications(jobPostingId);
      state = state.copyWith(items: result.items, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobApplicationsProvider =
    StateNotifierProvider.family<JobApplicationsNotifier, JobApplicationsState,
        String>((ref, jobPostingId) {
  return JobApplicationsNotifier(ref.watch(freelanceRepositoryProvider));
});

// ==================== Check-ins ====================
final checkInsProvider =
    FutureProvider.family<List<JobCheckInModel>, String>((ref, applicationId) {
  return ref
      .read(freelanceRepositoryProvider)
      .getApplicationCheckIns(applicationId);
});

// ==================== Reputation ====================
final reputationProvider =
    FutureProvider.family<ReputationModel, (String, int)>((ref, args) {
  return ref
      .read(freelanceRepositoryProvider)
      .getReputation(args.$1, args.$2);
});

// ==================== My templates ====================
final myTemplatesProvider = FutureProvider<List<JobTemplateModel>>((ref) {
  return ref.read(freelanceRepositoryProvider).getMyTemplates();
});

// ==================== My preferences ====================
final myJobPreferencesProvider =
    FutureProvider<List<WorkerJobPreferenceModel>>((ref) {
  return ref.read(freelanceRepositoryProvider).getMyJobPreferences();
});