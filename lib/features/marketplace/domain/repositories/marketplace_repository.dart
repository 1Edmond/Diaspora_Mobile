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
import '../../domain/entities/enums.dart';
import '../../domain/entities/listing.dart';

abstract class IMarketplaceRepository {
  /// Distinct listing categories, derived from live listing data rather
  /// than a hardcoded list, so the filter UI never offers a category that
  /// returns zero results. Implements the "Load categories from API" TODO
  /// that used to live directly in filter_bottom_sheet.dart.
  Future<List<MarketplaceCategoryModel>> getCategories();

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
  });

  Future<ListingModel> getListing(String id);

  Future<PagedResult<ListingSummaryModel>> getMyListings({
    int page = 1,
    int pageSize = 20,
    int? status,
    bool? isStandardService,
  });

  Future<PagedResult<ListingSummaryModel>> getPendingListings({
    int page = 1,
    int pageSize = 20,
  });

  Future<ListingModel> createListing(CreateListingDto dto);

  Future<ListingModel> updateListing(String id, UpdateListingDto dto);

  Future<void> deleteListing(String id);

  Future<void> approveListing(String id);

  Future<void> rejectListing(String id, String reason);

  Future<void> suspendListing(String id);

  Future<void> addListingImage(String id, String imagePath);

  Future<void> removeListingImage(String id, String imagePath);

  Future<void> setAvailability(String id, List<AvailabilitySlotModel> slots);

  Future<PagedResult<ReviewModel>> getReviews({
    required String listingId,
    int page = 1,
    int pageSize = 20,
  });

  Future<ReviewModel> createReview(String listingId, CreateReviewDto dto);

  Future<ReviewModel> updateReview(String listingId, String reviewId, UpdateReviewDto dto);

  Future<void> deleteReview(String listingId, String reviewId);

  Future<void> replyToReview(String listingId, String reviewId, String replyText);

  Future<void> addFavorite(String listingId);

  Future<void> removeFavorite(String listingId);

  Future<PagedResult<ListingSummaryModel>> getMyFavorites({
    int page = 1,
    int pageSize = 20,
  });

  // Service-specific methods (unified in marketplace)
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
  });

  Future<ServiceRequestModel> createRequest(CreateServiceRequestDto dto);

  Future<PagedResult<ServiceRequestModel>> getMySentRequests({
    int page = 1,
    int pageSize = 20,
  });

  Future<PagedResult<ServiceRequestModel>> getMyReceivedRequests({
    int page = 1,
    int pageSize = 20,
  });

  Future<ServiceRequestModel> getRequest(String id);

  Future<void> acceptRequest(String id);

  Future<void> declineRequest(String id, String reason);

  Future<void> completeRequest(String id);

  Future<void> cancelRequest(String id, String reason);

  Future<void> linkChatThread(String requestId, String chatThreadId);

  Future<ProviderStatsModel> getMyProviderStats();

  Future<void> createReport(int targetType, String targetId, String reason);

  Future<PagedResult<ReportModel>> getPendingReports({
    int page = 1,
    int pageSize = 20,
  });

  Future<void> resolveReport(String id, int status, String? notes);
}