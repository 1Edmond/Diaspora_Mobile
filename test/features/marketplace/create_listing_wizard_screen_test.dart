import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/core/config/app_config.dart';
import 'package:diaspora_app/features/marketplace/data/models/marketplace_category_model.dart';
import 'package:diaspora_app/features/marketplace/presentation/controllers/marketplace_providers.dart';
import 'package:diaspora_app/features/marketplace/presentation/screens/create_listing_wizard_screen.dart';

void main() {
  final testCategories = [
    MarketplaceCategoryModel(
      id: AppConfig.parcelTransportCategoryId,
      name: 'Transport de colis',
      count: 10,
    ),
    const MarketplaceCategoryModel(
      id: 'cat-housing',
      name: 'Logement & Hébergement',
      count: 5,
    ),
    const MarketplaceCategoryModel(
      id: 'cat-translation',
      name: 'Traduction & Interprétariat',
      count: 3,
    ),
  ];

  testWidgets('CreateListingWizardScreen renders dynamic categories from provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketplaceCategoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
        child: const MaterialApp(
          home: CreateListingWizardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choisissez votre catégorie'), findsOneWidget);
    expect(find.text('Transport de colis'), findsWidgets);
    expect(find.text('Logement & Hébergement'), findsOneWidget);
    expect(find.text('Traduction & Interprétariat'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('Selecting parcel transport dynamically reveals corridor fields, other category hides them', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketplaceCategoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
        child: const MaterialApp(
          home: CreateListingWizardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Default category is parcel transport -> corridor box should be visible
    expect(find.text('Corridor de transport'), findsOneWidget);

    // Tap on 'Logement & Hébergement'
    await tester.tap(find.text('Logement & Hébergement'));
    await tester.pumpAndSettle();

    // Corridor fields should now be hidden
    expect(find.text('Corridor de transport'), findsNothing);

    // Tap back on 'Transport de colis'
    await tester.tap(find.text('Transport de colis').first);
    await tester.pumpAndSettle();

    // Corridor fields reappear
    expect(find.text('Corridor de transport'), findsOneWidget);
  });
}
