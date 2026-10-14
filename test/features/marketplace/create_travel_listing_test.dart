import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/features/marketplace/presentation/screens/create_travel_listing_screen.dart';

void main() {
  Widget buildTestableWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: CreateTravelListingScreen(),
      ),
    );
  }

  group('CreateTravelListingScreen Widget Tests', () {
    testWidgets('displays step 1 corridor selectors and progresses through wizard', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Step 1: Corridor
      expect(find.text('Publier un trajet'), findsOneWidget);
      expect(find.text('Corridor & Itinéraire'), findsWidgets);
      expect(find.byKey(const Key('departure_country_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('arrival_country_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('departure_city_field')), findsOneWidget);
      expect(find.byKey(const Key('arrival_city_field')), findsOneWidget);

      // Enter cities
      await tester.enterText(find.byKey(const Key('departure_city_field')), 'Lomé');
      await tester.enterText(find.byKey(const Key('arrival_city_field')), 'Moscou');
      await tester.pumpAndSettle();

      // Next to step 2: Dates
      final nextButton = find.byKey(const Key('wizard_next_button'));
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Dates du voyage'), findsWidgets);
      expect(find.byKey(const Key('departure_date_tile')), findsOneWidget);
      expect(find.byKey(const Key('arrival_date_tile')), findsOneWidget);
      expect(find.byKey(const Key('pickup_deadline_tile')), findsOneWidget);

      // Next to step 3: Capacité & Tarification
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Capacité & Tarifs'), findsWidgets);
      expect(find.byKey(const Key('capacity_kg_field')), findsOneWidget);
      expect(find.byKey(const Key('price_per_kg_field')), findsOneWidget);

      // Enter capacity and price
      await tester.enterText(find.byKey(const Key('capacity_kg_field')), '20');
      await tester.enterText(find.byKey(const Key('price_per_kg_field')), '5000');
      await tester.pumpAndSettle();

      // Verify estimated earnings calculation: 20 kg * 5000 XOF = 100 000 XOF
      expect(find.textContaining('100 000'), findsOneWidget);

      // Next to step 4: Conditions & Remise
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Conditions & Remise'), findsWidgets);
      expect(find.byKey(const Key('transport_mode_selector')), findsOneWidget);
      expect(find.byKey(const Key('submit_travel_listing_button')), findsOneWidget);
    });

    testWidgets('validates required fields on step 1', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Clear departure city and try to proceed
      await tester.enterText(find.byKey(const Key('departure_city_field')), '');
      await tester.pumpAndSettle();

      final nextButton = find.byKey(const Key('wizard_next_button'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should remain on step 1
      expect(find.text('Corridor & Itinéraire'), findsWidgets);
      expect(find.textContaining('Veuillez renseigner la ville de départ'), findsOneWidget);
    });

    testWidgets('allows swapping corridor countries and cities', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('departure_city_field')), 'Lomé');
      await tester.enterText(find.byKey(const Key('arrival_city_field')), 'Moscou');
      await tester.pumpAndSettle();

      final swapButton = find.byKey(const Key('swap_corridor_button'));
      expect(swapButton, findsOneWidget);
      await tester.ensureVisible(swapButton);
      await tester.tap(swapButton);
      await tester.pumpAndSettle();

      final depField = tester.widget<TextFormField>(find.byKey(const Key('departure_city_field')));
      final arrField = tester.widget<TextFormField>(find.byKey(const Key('arrival_city_field')));

      expect(depField.controller?.text, 'Moscou');
      expect(arrField.controller?.text, 'Lomé');
    });

    testWidgets('validates capacity and price > 0 on step 3', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final nextButton = find.byKey(const Key('wizard_next_button'));
      // Step 1 -> Step 2
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2 -> Step 3
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Set capacity to 0
      await tester.enterText(find.byKey(const Key('capacity_kg_field')), '0');
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Veuillez indiquer une capacité valide'), findsOneWidget);
    });
  });
}
