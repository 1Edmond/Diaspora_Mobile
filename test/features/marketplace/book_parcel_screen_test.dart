import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/features/marketplace/data/models/listing_model.dart';
import 'package:diaspora_app/features/marketplace/presentation/screens/book_parcel_screen.dart';

import 'package:diaspora_app/core/constants/enums.dart';
import 'package:diaspora_app/features/marketplace/domain/entities/enums.dart';
import 'package:diaspora_app/features/profile/domain/entities/profile.dart';
import 'package:diaspora_app/features/profile/presentation/controllers/profile_providers.dart';

void main() {
  final mockActiveProfile = Profile(
    id: 'profile-test-1',
    userId: 'user-test-1',
    profileType: 'Internal',
    profileTypeId: 'pt-1',
    firstName: 'Jean',
    lastName: 'Dupont',
    status: ProfileStatus.VALIDATED,
    createdAt: DateTime.now(),
  );

  final testTravelListing = ListingModel(
    id: 'travel-listing-1',
    providerId: 'traveler-user-1',
    providerProfileId: 'profile-traveler-1',
    providerName: 'Kofi Traveler',
    providerIsVerified: true,
    providerCountryCode: 'TG',
    categoryId: 'travel-parcels',
    categoryName: 'Transport de colis',
    title: 'Transport de colis : Lomé 🇹🇬 ➔ Moscou 🇷🇺',
    description: 'Vol régulier Lomé - Moscou',
    paymentMode: 1,
    price: 5000.0,
    currency: 'XOF',
    status: 1,
    isActive: true,
    imageUrls: const [],
    averageRating: 4.9,
    reviewCount: 8,
    viewCount: 42,
    createdAt: DateTime.now(),
    availabilitySlots: const [],
    isAvailableNow: true,
    departureCountryCode: 'TG',
    departureCity: 'Lomé',
    arrivalCountryCode: 'RU',
    arrivalCity: 'Moscou',
    departureDate: DateTime.now().add(const Duration(days: 7)),
    arrivalDate: DateTime.now().add(const Duration(days: 8)),
    pickupDeadline: DateTime.now().add(const Duration(days: 6)),
    capacityKg: 20.0,
    remainingKg: 15.0,
    pricePerKg: 5000.0,
    transportMode: 'Avion',
  );

  Widget buildTestableWidget({ListingModel? listing, Profile? profile, AllowedSettlementPolicy? policy}) {
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWithValue(profile ?? mockActiveProfile),
      ],
      child: MaterialApp(
        home: BookParcelScreen(
          listingId: (listing ?? testTravelListing).id,
          listing: listing ?? testTravelListing,
          policy: policy,
        ),
      ),
    );
  }

  group('BookParcelScreen Widget Tests', () {
    testWidgets('displays travel listing summary, live calculation of traveler amount and platform fee', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Top travel summary
      expect(find.text('Réserver un espace colis'), findsOneWidget);
      expect(find.textContaining('Lomé'), findsWidgets);
      expect(find.textContaining('Moscou'), findsWidgets);
      expect(find.textContaining('Kofi Traveler'), findsOneWidget);
      expect(find.textContaining('15 kg'), findsWidgets);

      // Saisie des kilos souhaités (default: 1.0 or 2.0)
      expect(find.byKey(const Key('requested_weight_field')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('requested_weight_field')), '5');
      await tester.pumpAndSettle();

      // Live breakdown calculation:
      // Montant voyageur : 5 kg * 5000 = 25 000 XOF
      // Frais plateforme 10% : 2 500 XOF
      // Total sous séquestre : 27 500 XOF
      expect(find.textContaining('25 000'), findsWidgets);
      expect(find.textContaining('2 500'), findsWidgets);
      expect(find.textContaining('27 500'), findsWidgets);

      // Nature and declared value
      expect(find.byKey(const Key('parcel_nature_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('declared_value_field')), findsOneWidget);
      expect(find.byKey(const Key('sender_message_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_escrow_booking_button')), findsOneWidget);
    });

    testWidgets('validates requested weight against remaining capacity (> 0 and <= remainingKg)', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Enter weight exceeding remaining capacity (25 kg > 15 kg remaining)
      await tester.enterText(find.byKey(const Key('requested_weight_field')), '25');
      await tester.pumpAndSettle();

      // Attempt to submit
      final confirmBtn = find.byKey(const Key('confirm_escrow_booking_button'));
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('dépasse les 15 kg disponibles'), findsOneWidget);

      // Enter zero weight
      await tester.enterText(find.byKey(const Key('requested_weight_field')), '0');
      await tester.pumpAndSettle();

      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('supérieur à 0 kg'), findsOneWidget);
    });

    testWidgets('shows warning banner and disables booking when profile is not active', (tester) async {
      final suspendedProfile = mockActiveProfile.copyWith(status: ProfileStatus.REJECTED);
      await tester.pumpWidget(buildTestableWidget(profile: suspendedProfile));
      await tester.pumpAndSettle();

      expect(find.textContaining('Votre profil doit être actif et validé'), findsOneWidget);

      final confirmBtn = tester.widget<ElevatedButton>(find.byKey(const Key('confirm_escrow_booking_button')));
      expect(confirmBtn.onPressed, isNull);
    });

    testWidgets('displays settlement options and switches dynamically to direct cash with breakdown and timing', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Check Option A (Escrow) is present with badge and explanation
      expect(find.text('Protection Diaspora 100%'), findsOneWidget);
      expect(
        find.textContaining('Vos fonds sont bloqués en toute sécurité sur votre portefeuille'),
        findsOneWidget,
      );

      // Check Option B (Direct Handover) is present with badge and explanation
      expect(find.text('Paiement en main propre'), findsOneWidget);
      expect(
        find.textContaining('Vous remettrez le montant convenu directement au voyageur en espèces'),
        findsOneWidget,
      );

      // Default is Escrow -> confirm button says "Confirmer et bloquer sous séquestre"
      expect(find.text('Confirmer et bloquer sous séquestre'), findsOneWidget);

      // Tap on Option B (Direct Cash)
      final directOption = find.byKey(const Key('settlement_option_direct_handover'));
      await tester.ensureVisible(directOption);
      await tester.tap(directOption);
      await tester.pumpAndSettle();

      // Cash timing options should appear
      expect(find.byKey(const Key('cash_timing_pickup')), findsOneWidget);
      expect(find.byKey(const Key('cash_timing_delivery')), findsOneWidget);

      // Dynamic price breakdown should update
      expect(find.textContaining('Frais de réservation :'), findsOneWidget);
      expect(find.textContaining('Montant en espèces à remettre au voyageur :'), findsOneWidget);
      expect(find.text('Confirmer la réservation directe'), findsOneWidget);

      // Toggle cash timing to delivery
      await tester.tap(find.byKey(const Key('cash_timing_delivery')));
      await tester.pumpAndSettle();

      // Switch back to Option A (Escrow)
      final escrowOption = find.byKey(const Key('settlement_option_wallet_escrow'));
      await tester.ensureVisible(escrowOption);
      await tester.tap(escrowOption);
      await tester.pumpAndSettle();

      expect(find.text('Confirmer et bloquer sous séquestre'), findsOneWidget);
      expect(find.text('Total sous séquestre sécurisé'), findsOneWidget);
    });

    testWidgets('enforces AllowedSettlementPolicy when restricted', (tester) async {
      // 1. walletEscrowOnly: Direct handover option is hidden
      await tester.pumpWidget(buildTestableWidget(policy: AllowedSettlementPolicy.walletEscrowOnly));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settlement_option_wallet_escrow')), findsOneWidget);
      expect(find.byKey(const Key('settlement_option_direct_handover')), findsNothing);

      // 2. directHandoverOnly: Escrow option is hidden and Direct Cash is auto-selected
      await tester.pumpWidget(buildTestableWidget(policy: AllowedSettlementPolicy.directHandoverOnly));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settlement_option_wallet_escrow')), findsNothing);
      expect(find.byKey(const Key('settlement_option_direct_handover')), findsOneWidget);
      final confirmBtn = find.byKey(const Key('confirm_escrow_booking_button'));
      await tester.ensureVisible(confirmBtn);
      await tester.pumpAndSettle();
      expect(find.text('Confirmer la réservation directe'), findsOneWidget);
    });
  });
}
