import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/job_category_model.dart';
import '../../data/models/job_posting_model.dart';
import '../../data/models/job_application_model.dart';
import '../../domain/repositories/freelance_repository.dart';

final freelanceRepositoryProvider = Provider<IFreelanceRepository>((ref) {
  return GetIt.instance<IFreelanceRepository>();
});

// ==================== Categories ====================
final jobCategoriesProvider = FutureProvider<List<JobCategoryModel>>((ref) {
  return ref.read(freelanceRepositoryProvider).getCategories();
});

// ==================== Catalogue search ====================
class JobSearchState {
  final List<JobPostingSummaryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int totalCount;
  final String? error;
  final String? searchQuery;
  final String? selectedCategoryId;
  final String? city;
  final String? country;
  final bool? isRemote;
  final int? paymentType;
  final double? minAmount;
  final double? maxAmount;
  final double? userLat;
  final double? userLng;
  final double? maxDistanceKm;

  const JobSearchState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
    this.searchQuery,
    this.selectedCategoryId,
    this.city,
    this.country,
    this.isRemote,
    this.paymentType,
    this.minAmount,
    this.maxAmount,
    this.userLat,
    this.userLng,
    this.maxDistanceKm,
  });

  JobSearchState copyWith({
    List<JobPostingSummaryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? totalCount,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
    String? city,
    String? country,
    bool? isRemote,
    int? paymentType,
    double? minAmount,
    double? maxAmount,
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearCountry = false,
  }) {
    return JobSearchState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
      searchQuery: clearSearch
          ? null
          : (searchQuery ?? this.searchQuery),
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      city: clearCity ? null : (city ?? this.city),
      country: clearCountry ? null : (country ?? this.country),
      isRemote: isRemote ?? this.isRemote,
      paymentType: paymentType ?? this.paymentType,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      selectedCategoryId != null ||
      city != null ||
      country != null ||
      isRemote != null ||
      paymentType != null ||
      minAmount != null ||
      maxAmount != null;
}

class JobSearchNotifier extends StateNotifier<JobSearchState> {
  final IFreelanceRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  JobSearchNotifier(this._repository) : super(const JobSearchState());

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        isLoading: true,
        error: null,
        items: const [],
        hasNext: true,
      );
    } else if (state.isLoading || state.isLoadingMore || !state.hasNext) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }
    try {
      final result = await _repository.getJobPostings(
        page: _currentPage,
        pageSize: _pageSize,
        categoryId: state.selectedCategoryId,
        search: state.searchQuery,
        paymentType: state.paymentType,
        minAmount: state.minAmount,
        maxAmount: state.maxAmount,
        city: state.city,
        country: state.country,
        isRemote: state.isRemote,
        userLatitude: state.userLat,
        userLongitude: state.userLng,
        maxDistanceKm: state.maxDistanceKm,
      );
      final newItems = refresh || _currentPage == 1
          ? result.items
          : [...state.items, ...result.items];
      state = state.copyWith(
        items: newItems,
        isLoading: false,
        isLoadingMore: false,
        hasNext: result.hasNext,
        totalCount: result.totalCount,
        error: null,
      );
      _currentPage++;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasNext || state.isLoading) return;
    await fetch();
  }

  void setFilters({
    String? searchQuery,
    String? categoryId,
    String? city,
    String? country,
    bool? isRemote,
    int? paymentType,
    double? minAmount,
    double? maxAmount,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      selectedCategoryId: categoryId,
      city: city,
      country: country,
      isRemote: isRemote,
      paymentType: paymentType,
      minAmount: minAmount,
      maxAmount: maxAmount,
    );
    fetch(refresh: true);
  }

  void setUserLocation(double lat, double lng, {double? maxDistanceKm}) {
    state = state.copyWith(
      userLat: lat,
      userLng: lng,
      maxDistanceKm: maxDistanceKm,
    );
    fetch(refresh: true);
  }
}

final jobSearchProvider =
    StateNotifierProvider<JobSearchNotifier, JobSearchState>((ref) {
  return JobSearchNotifier(ref.watch(freelanceRepositoryProvider));
});

// ==================== Job detail ====================
class JobDetailState {
  final JobPostingModel? posting;
  final bool isLoading;
  final String? error;

  const JobDetailState({this.posting, this.isLoading = false, this.error});

  JobDetailState copyWith({
    JobPostingModel? posting,
    bool? isLoading,
    String? error,
  }) {
    return JobDetailState(
      posting: posting ?? this.posting,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobDetailNotifier extends StateNotifier<JobDetailState> {
  final IFreelanceRepository _repository;
  JobDetailNotifier(this._repository) : super(const JobDetailState());

  Future<void> load(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posting = await _repository.getJobPosting(id);
      state = state.copyWith(posting: posting, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final jobDetailProvider = StateNotifierProvider.family<JobDetailNotifier,
    JobDetailState, String>((ref, id) {
  return JobDetailNotifier(ref.watch(freelanceRepositoryProvider));
});

// ==================== My applications (worker) ====================
class MyApplicationsState {
  final List<JobApplicationModel> items;
  final bool isLoading;
  final String? error;

  const MyApplicationsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MyApplicationsState copyWith({
    List<JobApplicationModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return MyApplicationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MyApplicationsNotifier extends StateNotifier<MyApplicationsState> {
  final IFreelanceRepository _repository;
  MyApplicationsNotifier(this._repository) : super(const MyApplicationsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getMyApplications();
      state = state.copyWith(items: result.items, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> apply(String jobPostingId, String? message) async {
    await _repository.applyToJob(jobPostingId, message);
    await load();
  }

  Future<void> withdraw(String id) async {
    await _repository.withdrawApplication(id);
    await load();
  }
}

final myApplicationsProvider =
    StateNotifierProvider<MyApplicationsNotifier, MyApplicationsState>((ref) {
  return MyApplicationsNotifier(ref.watch(freelanceRepositoryProvider));
});