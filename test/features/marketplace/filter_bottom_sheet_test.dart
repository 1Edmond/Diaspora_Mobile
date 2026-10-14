import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/features/marketplace/presentation/widgets/filter_bottom_sheet.dart';
import 'package:diaspora_app/features/marketplace/presentation/controllers/marketplace_providers.dart';
import 'package:diaspora_app/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:diaspora_app/features/marketplace/data/models/marketplace_category_model.dart';
import 'package:diaspora_app/features/marketplace/data/models/paged_result.dart';
import 'package:diaspora_app/features/marketplace/data/models/listing_summary_model.dart';
import 'package:diaspora_app/features/marketplace/domain/entities/enums.dart';
import 'package:diaspora_app/features/marketplace/domain/entities/listing.dart';

class FakeMarketplaceRepository implements IMarketplaceRepository {
  @override
  Future<List<MarketplaceCategoryModel>> getCategories() async {
    return const [
      MarketplaceCategoryModel(id: 'transport-colis', name: 'Transport de colis', count: 5),
      MarketplaceCategoryModel(id: 'logement', name: 'Logement', count: 2),
    ];
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
    return const PagedResult<ListingSummaryModel>(
      items: [],
      totalCount: 0,
      pageNumber: 1,
      pageSize: 20,
      totalPages: 1,
      hasNext: false,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('FilterBottomSheet renders and toggles category', (tester) async {
    final fakeRepo = FakeMarketplaceRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketplaceRepositoryProvider.overrideWithValue(fakeRepo),
          marketplaceCategoriesProvider.overrideWith((ref) => fakeRepo.getCategories()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FilterBottomSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filtres de recherche'), findsOneWidget);
    expect(find.text('Catégorie de service'), findsOneWidget);
    expect(find.text('Transport de colis ✈️📦'), findsOneWidget);

    // Tap on Transport de colis
    await tester.tap(find.text('Transport de colis ✈️📦'));
    await tester.pumpAndSettle();

    // Corridor should appear
    expect(find.text('Corridor de voyage (Colis) ✈️📦'), findsOneWidget);
  });
}
