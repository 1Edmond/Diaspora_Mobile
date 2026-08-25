import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/paged_result.dart';
import '../../data/models/listing_summary_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/provider_stats_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/service_request_model.dart';
import '../../data/models/availability_slot_model.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/entities/enums.dart';

final marketplaceRepositoryProvider = Provider((ref) {
  return GetIt.instance<IMarketplaceRepository>();
});

final favoriteIdsProvider = StateProvider<Set<String>>((ref) => {});

class MarketplaceState {
  final List<ListingSummaryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int totalCount;
  final String? error;
  final String searchQuery;
  final String? selectedCategoryId;
  final ListingSortBy sortBy;
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final String? country;
  final bool availableNow;
  final double? userLat;
  final double? userLng;
  final double? maxDistanceKm;

  const MarketplaceState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.sortBy = ListingSortBy.relevance,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.country,
    this.availableNow = false,
    this.userLat,
    this.userLng,
    this.maxDistanceKm,
  });

  MarketplaceState copyWith({
    List<ListingSummaryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? totalCount,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
    ListingSortBy? sortBy,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? country,
    bool? availableNow,
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
    bool clearSearchQuery = false,
    bool clearCategoryId = false,
    bool clearPriceRange = false,
    bool clearLocation = false,
  }) {
    return MarketplaceState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      selectedCategoryId: clearCategoryId ? null : (selectedCategoryId ?? this.selectedCategoryId),
      sortBy: sortBy ?? this.sortBy,
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      city: clearLocation ? null : (city ?? this.city),
      country: clearLocation ? null : (country ?? this.country),
      availableNow: availableNow ?? this.availableNow,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategoryId != null ||
      minPrice != null ||
      maxPrice != null ||
      city != null ||
      country != null ||
      availableNow;
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final IMarketplaceRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  MarketplaceNotifier({required IMarketplaceRepository repository})
      : _repository = repository,
        super(const MarketplaceState());

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, error: null, items: [], hasNext: true);
    } else if (state.isLoading || state.isLoadingMore || !state.hasNext) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final result = await _repository.searchListings(
        page: _currentPage,
        pageSize: _pageSize,
        categoryId: state.selectedCategoryId,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        sortBy: state.sortBy,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        city: state.city,
        country: state.country,
        userLat: state.userLat,
        userLng: state.userLng,
        maxDistanceKm: state.maxDistanceKm,
        availableNow: state.availableNow,
      );

      if (refresh || _currentPage == 1) {
        state = state.copyWith(
          items: result.items,
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...result.items],
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      }
      _currentPage++;
    } catch (e, st) {
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, clearCategoryId: true);
    fetch(refresh: true);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    fetch(refresh: true);
  }

  void setSortBy(ListingSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
    fetch(refresh: true);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max, clearPriceRange: min == null && max == null);
    fetch(refresh: true);
  }

  void setLocation(String? city, String? country) {
    state = state.copyWith(city: city, country: country, clearLocation: city == null && country == null);
    fetch(refresh: true);
  }

  void setUserLocation(double lat, double lng, {double? maxDistanceKm}) {
    state = state.copyWith(userLat: lat, userLng: lng, maxDistanceKm: maxDistanceKm);
    fetch(refresh: true);
  }

  void setAvailableNow(bool value) {
    state = state.copyWith(availableNow: value);
    fetch(refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      clearSearchQuery: true,
      clearCategoryId: true,
      clearPriceRange: true,
      clearLocation: true,
      availableNow: false,
      sortBy: ListingSortBy.relevance,
      userLat: null,
      userLng: null,
      maxDistanceKm: null,
    );
    fetch(refresh: true);
  }
}

final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier(repository: ref.watch(marketplaceRepositoryProvider));
});

class MyListingsState {
  final List<ListingSummaryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int totalCount;
  final String? error;
  final int? statusFilter;

  const MyListingsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
    this.statusFilter,
  });

  MyListingsState copyWith({
    List<ListingSummaryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? totalCount,
    String? error,
    int? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return MyListingsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class MyListingsNotifier extends StateNotifier<MyListingsState> {
  final IMarketplaceRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  MyListingsNotifier({required IMarketplaceRepository repository})
      : _repository = repository,
        super(const MyListingsState());

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, error: null, items: [], hasNext: true);
    } else if (state.isLoading || state.isLoadingMore || !state.hasNext) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final result = await _repository.getMyListings(
        page: _currentPage,
        pageSize: _pageSize,
        status: state.statusFilter,
      );

      if (refresh || _currentPage == 1) {
        state = state.copyWith(
          items: result.items,
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...result.items],
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      }
      _currentPage++;
    } catch (e, st) {
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

  void setStatusFilter(int? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    fetch(refresh: true);
  }

  Future<void> deleteListing(String id) async {
    await _repository.deleteListing(id);
    state = state.copyWith(items: state.items.where((l) => l.id != id).toList());
  }

  Future<void> approveListing(String id) async {
    await _repository.approveListing(id);
    await fetch(refresh: true);
  }

  Future<void> rejectListing(String id, String reason) async {
    await _repository.rejectListing(id, reason);
    await fetch(refresh: true);
  }

  Future<void> suspendListing(String id) async {
    await _repository.suspendListing(id);
    await fetch(refresh: true);
  }
}

final myListingsProvider = StateNotifierProvider<MyListingsNotifier, MyListingsState>((ref) {
  return MyListingsNotifier(repository: ref.watch(marketplaceRepositoryProvider));
});

class ListingDetailState {
  final ListingModel? listing;
  final bool isLoading;
  final String? error;
  final bool isFavorite;

  const ListingDetailState({
    this.listing,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
  });

  ListingDetailState copyWith({
    ListingModel? listing,
    bool? isLoading,
    String? error,
    bool? isFavorite,
    bool clearListing = false,
  }) {
    return ListingDetailState(
      listing: clearListing ? null : (listing ?? this.listing),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ListingDetailNotifier extends StateNotifier<ListingDetailState> {
  final IMarketplaceRepository _repository;
  final Ref ref;

  ListingDetailNotifier({required IMarketplaceRepository repository, required this.ref})
      : _repository = repository,
        super(const ListingDetailState());

  Future<void> load(String id) async {
    state = state.copyWith(isLoading: true, error: null, clearListing: true);
    try {
      final listing = await _repository.getListing(id);
      final isFav = ref.read(favoriteIdsProvider).contains(id);
      state = state.copyWith(listing: listing, isLoading: false, isFavorite: isFav);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), clearListing: true);
    }
  }

  Future<void> toggleFavorite() async {
    final id = state.listing?.id;
    if (id == null) return;
    final current = state.isFavorite;
    try {
      if (current) {
        await _repository.removeFavorite(id);
      } else {
        await _repository.addFavorite(id);
      }
      state = state.copyWith(isFavorite: !current);
      if (!current) {
        ref.read(favoriteIdsProvider.notifier).state = {...ref.read(favoriteIdsProvider)}..add(state.listing!.id);
      } else {
        ref.read(favoriteIdsProvider.notifier).state = {...ref.read(favoriteIdsProvider)}..remove(id);
      }
    } catch (e) {
      // rollback handled by UI
    }
  }

  Future<void> approve() async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.approveListing(id);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }

  Future<void> reject(String reason) async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.rejectListing(id, reason);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }

  Future<void> suspend() async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.suspendListing(id);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }

  Future<void> addImage(String path) async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.addListingImage(id, path);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }

  Future<void> removeImage(String path) async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.removeListingImage(id, path);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }

  Future<void> setAvailability(List<AvailabilitySlotModel> slots) async {
    final id = state.listing?.id;
    if (id == null) return;
    await _repository.setAvailability(id, slots);
    final updated = await _repository.getListing(id);
    state = state.copyWith(listing: updated);
  }
}

final listingDetailProvider = StateNotifierProvider.family<ListingDetailNotifier, ListingDetailState, String>((ref, id) {
  return ListingDetailNotifier(repository: ref.watch(marketplaceRepositoryProvider), ref: ref);
});

final reviewsProvider = FutureProvider.family<PagedResult<ReviewModel>, String>((ref, listingId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getReviews(listingId: listingId, page: 1, pageSize: 20);
});

final providerStatsProvider = FutureProvider<ProviderStatsModel>((ref) async {
  return ref.read(marketplaceRepositoryProvider).getMyProviderStats();
});

class FavoritesState {
  final List<ListingSummaryModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int totalCount;
  final String? error;

  const FavoritesState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.totalCount = 0,
    this.error,
  });

  FavoritesState copyWith({
    List<ListingSummaryModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? totalCount,
    String? error,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final IMarketplaceRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  FavoritesNotifier({required IMarketplaceRepository repository})
      : _repository = repository,
        super(const FavoritesState());

  Future<void> fetch({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(isLoading: true, error: null, items: [], hasNext: true);
    } else if (state.isLoading || state.isLoadingMore || !state.hasNext) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final result = await _repository.getMyFavorites(page: _currentPage, pageSize: _pageSize);

      if (refresh || _currentPage == 1) {
        state = state.copyWith(
          items: result.items,
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...result.items],
          isLoading: false,
          isLoadingMore: false,
          hasNext: result.hasNext,
          totalCount: result.totalCount,
          error: null,
        );
      }
      _currentPage++;
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasNext || state.isLoading) return;
    await fetch();
  }

  Future<void> removeFavorite(String id) async {
    await _repository.removeFavorite(id);
    state = state.copyWith(items: state.items.where((l) => l.id != id).toList());
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(repository: ref.watch(marketplaceRepositoryProvider));
});

class ServiceRequestsState {
  final List<ServiceRequestModel> sentItems;
  final List<ServiceRequestModel> receivedItems;
  final bool isLoadingSent;
  final bool isLoadingReceived;
  final String? error;

  const ServiceRequestsState({
    this.sentItems = const [],
    this.receivedItems = const [],
    this.isLoadingSent = false,
    this.isLoadingReceived = false,
    this.error,
  });

  ServiceRequestsState copyWith({
    List<ServiceRequestModel>? sentItems,
    List<ServiceRequestModel>? receivedItems,
    bool? isLoadingSent,
    bool? isLoadingReceived,
    String? error,
  }) {
    return ServiceRequestsState(
      sentItems: sentItems ?? this.sentItems,
      receivedItems: receivedItems ?? this.receivedItems,
      isLoadingSent: isLoadingSent ?? this.isLoadingSent,
      isLoadingReceived: isLoadingReceived ?? this.isLoadingReceived,
      error: error,
    );
  }
}

class ServiceRequestsNotifier extends StateNotifier<ServiceRequestsState> {
  final IMarketplaceRepository _repository;

  ServiceRequestsNotifier({required IMarketplaceRepository repository})
      : _repository = repository,
        super(const ServiceRequestsState());

  Future<void> loadSent() async {
    state = state.copyWith(isLoadingSent: true, error: null);
    try {
      final result = await _repository.getMySentRequests(page: 1, pageSize: 20);
      state = state.copyWith(sentItems: result.items, isLoadingSent: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoadingSent: false, error: e.toString());
    }
  }

  Future<void> loadReceived() async {
    state = state.copyWith(isLoadingReceived: true, error: null);
    try {
      final result = await _repository.getMyReceivedRequests(page: 1, pageSize: 20);
      state = state.copyWith(receivedItems: result.items, isLoadingReceived: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoadingReceived: false, error: e.toString());
    }
  }

  Future<void> acceptRequest(String id) async {
    await _repository.acceptRequest(id);
    await loadReceived();
  }

  Future<void> declineRequest(String id, String reason) async {
    await _repository.declineRequest(id, reason);
    await loadReceived();
  }

  Future<void> completeRequest(String id) async {
    await _repository.completeRequest(id);
    await loadReceived();
  }

  Future<void> cancelRequest(String id, String reason) async {
    await _repository.cancelRequest(id, reason);
    await loadSent();
  }
}

final serviceRequestsProvider = StateNotifierProvider<ServiceRequestsNotifier, ServiceRequestsState>((ref) {
  return ServiceRequestsNotifier(repository: ref.watch(marketplaceRepositoryProvider));
});

final pendingReportsProvider = FutureProvider<PagedResult<ReportModel>>((ref) async {
  return ref.read(marketplaceRepositoryProvider).getPendingReports(page: 1, pageSize: 20);
});