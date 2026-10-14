import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/features/marketplace/presentation/screens/create_listing_wizard_screen.dart';

void main() {
  testWidgets('CreateListingWizardScreen renders step 1 with category first', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateListingWizardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choisissez votre catégorie'), findsOneWidget);
    expect(find.text('Transport de colis ✈️📦'), findsWidgets);
    expect(find.text('Continuer'), findsOneWidget);
  });
}
