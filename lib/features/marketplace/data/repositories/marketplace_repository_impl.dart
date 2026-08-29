import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/paged_result.dart';
import '../../data/models/listing_summary_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/provider_stats_model.dart';
import '../../data/models/report_model.dart';
import '../../data/models/service_request_model.dart';
import '../../data/models/marketplace_dtos.dart';
import '../../data/models/availability_slot_model.dart';
import '../../data/models/marketplace_category_model.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/listing.dart';
import '../../../../core/network/dio_client.dart';

class MarketplaceRepositoryImpl implements IMarketplaceRepository {
  final DioClient _client;

  MarketplaceRepositoryImpl({required DioClient client}) : _client = client;

  @override
  Future<List<MarketplaceCategoryModel>> getCategories() async {
    final res = await _client.get('/listings/categories');
    final list = (res as List<dynamic>? ?? []);
    return list
        .map((json) => MarketplaceCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PagedResult<ListingSummaryModel>> searchListings({
    int page = 1,
    int pageSize = 20,
    String? categoryId,
    String? search,
    int? paymentMode,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? country,
    ListingSortBy sortBy = ListingSortBy.relevance,
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
    bool availableNow = false,
    bool? isStandardService,
    ServiceCategory? serviceCategory,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (paymentMode != null) queryParams['paymentMode'] = paymentMode;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (country != null && country.isNotEmpty) queryParams['country'] = country;
    queryParams['sortBy'] = sortBy.index;
    if (userLat != null) queryParams['userLatitude'] = userLat;
    if (userLng != null) queryParams['userLongitude'] = userLng;
    if (maxDistanceKm != null) queryParams['maxDistanceKm'] = maxDistanceKm;
    if (availableNow) queryParams['availableNow'] = true;
    if (isStandardService != null) queryParams['isStandardService'] = isStandardService;
    if (serviceCategory != null) queryParams['serviceCategory'] = serviceCategory.name;

    final res = await _client.get('/listings', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ListingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<PagedResult<ListingSummaryModel>> getServices({
    int page = 1,
    int pageSize = 20,
    ServiceCategory? category,
    String? search,
    PriceType? priceType,
    ServiceScope? scope,
    String? city,
    String? country,
    ListingSortBy sortBy = ListingSortBy.relevance,
    double? userLat,
    double? userLng,
    double? maxDistanceKm,
    bool availableNow = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'isStandardService': true,
    };
    if (category != null) queryParams['serviceCategory'] = category.name;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (priceType != null) queryParams['priceType'] = priceType.name;
    if (scope != null) queryParams['serviceScope'] = scope.name;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (country != null && country.isNotEmpty) queryParams['country'] = country;
    queryParams['sortBy'] = sortBy.index;
    if (userLat != null) queryParams['userLatitude'] = userLat;
    if (userLng != null) queryParams['userLongitude'] = userLng;
    if (maxDistanceKm != null) queryParams['maxDistanceKm'] = maxDistanceKm;
    if (availableNow) queryParams['availableNow'] = true;

    final res = await _client.get('/listings', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ListingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<ListingModel> getListing(String id) async {
    final res = await _client.get('/listings/$id');
    return ListingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<ListingSummaryModel>> getMyListings({
    int page = 1,
    int pageSize = 20,
    int? status,
    bool? isStandardService,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) queryParams['status'] = status;
    if (isStandardService != null) queryParams['isStandardService'] = isStandardService;

    final res = await _client.get('/listings/my', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ListingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<PagedResult<ListingSummaryModel>> getPendingListings({
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get('/listings/pending', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ListingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<ListingModel> createListing(CreateListingDto dto) async {
    final res = await _client.post('/listings', data: dto.toJson());
    return ListingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<ListingModel> updateListing(String id, UpdateListingDto dto) async {
    final res = await _client.put('/listings/$id', data: dto.toJson());
    return ListingModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteListing(String id) async {
    await _client.delete('/listings/$id');
  }

  @override
  Future<void> approveListing(String id) async {
    await _client.post('/listings/$id/approve');
  }

  @override
  Future<void> rejectListing(String id, String reason) async {
    await _client.post('/listings/$id/reject', data: {'reason': reason});
  }

  @override
  Future<void> suspendListing(String id) async {
    await _client.post('/listings/$id/suspend');
  }

  @override
  Future<void> addListingImage(String id, String imagePath) async {
    await _client.post('/listings/$id/images', data: {'imagePath': imagePath});
  }

  @override
  Future<void> removeListingImage(String id, String imagePath) async {
    await _client.delete('/listings/$id/images', data: {'imagePath': imagePath});
  }

  @override
  Future<void> setAvailability(String id, List<AvailabilitySlotModel> slots) async {
    await _client.put(
      '/listings/$id/availability',
      data: {'slots': slots.map((e) => e.toJson()).toList()},
    );
  }

  @override
  Future<PagedResult<ReviewModel>> getReviews({
    required String listingId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get(
      '/listings/$listingId/reviews',
      queryParameters: queryParams,
    );
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ReviewModel.fromJson(json),
    );
  }

  @override
  Future<ReviewModel> createReview(String listingId, CreateReviewDto dto) async {
    final res = await _client.post('/listings/$listingId/reviews', data: dto.toJson());
    return ReviewModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> updateReview(String listingId, String reviewId, UpdateReviewDto dto) async {
    final res = await _client.put('/listings/$listingId/reviews/$reviewId', data: dto.toJson());
    return ReviewModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReview(String listingId, String reviewId) async {
    await _client.delete('/listings/$listingId/reviews/$reviewId');
  }

  @override
  Future<void> replyToReview(String listingId, String reviewId, String replyText) async {
    await _client.post(
      '/listings/$listingId/reviews/$reviewId/reply',
      data: {'replyText': replyText},
    );
  }

  @override
  Future<void> addFavorite(String listingId) async {
    await _client.post('/listings/$listingId/favorite');
  }

  @override
  Future<void> removeFavorite(String listingId) async {
    await _client.delete('/listings/$listingId/favorite');
  }

  @override
  Future<PagedResult<ListingSummaryModel>> getMyFavorites({
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get('/favorites/my', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ListingSummaryModel.fromJson(json),
    );
  }

  @override
  Future<ServiceRequestModel> createRequest(CreateServiceRequestDto dto) async {
    final res = await _client.post('/service-requests', data: dto.toJson());
    return ServiceRequestModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<PagedResult<ServiceRequestModel>> getMySentRequests({
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get('/service-requests/my', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ServiceRequestModel.fromJson(json),
    );
  }

  @override
  Future<PagedResult<ServiceRequestModel>> getMyReceivedRequests({
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get('/service-requests/received', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ServiceRequestModel.fromJson(json),
    );
  }

  @override
  Future<ServiceRequestModel> getRequest(String id) async {
    final res = await _client.get('/service-requests/$id');
    return ServiceRequestModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> acceptRequest(String id) async {
    await _client.post('/service-requests/$id/accept');
  }

  @override
  Future<void> declineRequest(String id, String reason) async {
    await _client.post('/service-requests/$id/decline', data: {'reason': reason});
  }

  @override
  Future<void> completeRequest(String id) async {
    await _client.post('/service-requests/$id/complete');
  }

  @override
  Future<void> cancelRequest(String id, String reason) async {
    await _client.post('/service-requests/$id/cancel', data: {'reason': reason});
  }

  @override
  Future<void> linkChatThread(String requestId, String chatThreadId) async {
    await _client.post(
      '/service-requests/$requestId/chat-thread',
      data: {'chatThreadId': chatThreadId},
    );
  }

  @override
  Future<ProviderStatsModel> getMyProviderStats() async {
    final res = await _client.get('/listings/stats/my');
    return ProviderStatsModel.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> createReport(int targetType, String targetId, String reason) async {
    await _client.post('/reports', data: {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
    });
  }

  @override
  Future<PagedResult<ReportModel>> getPendingReports({
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    final res = await _client.get('/reports/pending', queryParameters: queryParams);
    return PagedResult.fromJson(
      res as Map<String, dynamic>,
      (json) => ReportModel.fromJson(json),
    );
  }

  @override
  Future<void> resolveReport(String id, int status, String? notes) async {
    await _client.post('/reports/$id/resolve', data: {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }
}

final marketplaceRepositoryProvider = Provider<IMarketplaceRepository>((ref) {
  return GetIt.instance<IMarketplaceRepository>();
});