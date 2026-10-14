import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diaspora_app/features/marketplace/data/models/service_request_model.dart';
import 'package:diaspora_app/features/marketplace/domain/entities/enums.dart';
import 'package:diaspora_app/features/marketplace/presentation/screens/parcel_tracking_screen.dart';

void main() {
  final testSenderRequest = ServiceRequestModel(
    id: 'req-tracking-1',
    listingId: 'listing-1',
    listingTitle: 'Transport Lomé ➔ Moscou',
    requesterId: 'sender-user-1',
    requesterName: 'Afi Expéditeur',
    providerId: 'traveler-user-2',
    providerName: 'Kofi Voyageur',
    message: 'Colis de 5kg (vêtements)',
    status: ServiceRequestStatus.accepted,
    agreedPrice: 25000.0,
    agreedCurrency: 'XOF',
    paymentStatus: PaymentStatus.held,
    createdAt: DateTime.now(),
    trackingStep: ParcelTrackingStep.bookingConfirmed,
    parcelWeightKg: 5.0,
    parcelNature: 'Vêtements & Textiles',
    declaredValue: 30000.0,
    pickupOtpCode: '482915',
    deliveryOtpCode: '739104',
    departureCountryCode: 'TG',
    departureCity: 'Lomé',
    arrivalCountryCode: 'RU',
    arrivalCity: 'Moscou',
  );

  Widget buildTestableWidget({required ServiceRequestModel request, bool isTraveler = false}) {
    return ProviderScope(
      child: MaterialApp(
        home: ParcelTrackingScreen(
          requestId: request.id,
          request: request,
          isTravelerRole: isTraveler,
        ),
      ),
    );
  }

  group('ParcelTrackingScreen Widget Tests', () {
    testWidgets('displays the 5 lifecycle tracking steps of the parcel', (tester) async {
      await tester.pumpWidget(buildTestableWidget(request: testSenderRequest));
      await tester.pumpAndSettle();

      // Top info
      expect(find.text('Suivi de livraison Colis'), findsOneWidget);
      expect(find.textContaining('Lomé'), findsWidgets);
      expect(find.textContaining('Moscou'), findsWidgets);
      expect(find.textContaining('5 kg'), findsWidgets);

      // Verify the 5 lifecycle steps are present in the timeline
      expect(find.textContaining('Réservation confirmée & Paiement sous séquestre'), findsOneWidget);
      expect(find.textContaining('Colis remis au voyageur'), findsOneWidget);
      expect(find.textContaining('En transit'), findsOneWidget);
      expect(find.textContaining('Arrivé dans la ville de destination'), findsOneWidget);
      expect(find.textContaining('Colis livré au destinataire'), findsOneWidget);
    });

    testWidgets('for sender, button to view pickup secret OTP code is visible and reveals dialog', (tester) async {
      await tester.pumpWidget(buildTestableWidget(request: testSenderRequest, isTraveler: false));
      await tester.pumpAndSettle();

      final viewOtpButton = find.byKey(const Key('view_pickup_otp_button'));
      expect(viewOtpButton, findsOneWidget);

      await tester.ensureVisible(viewOtpButton);
      await tester.tap(viewOtpButton);
      await tester.pumpAndSettle();

      // Secret OTP dialog should be displayed with digits
      expect(find.text('Votre code secret de remise'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('8'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.byKey(const Key('close_otp_dialog_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('close_otp_dialog_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('for traveler, button to enter OTP code is active and opens input dialog', (tester) async {
      await tester.pumpWidget(buildTestableWidget(request: testSenderRequest, isTraveler: true));
      await tester.pumpAndSettle();

      final enterOtpButton = find.byKey(const Key('enter_pickup_otp_button'));
      expect(enterOtpButton, findsOneWidget);

      await tester.ensureVisible(enterOtpButton);
      await tester.tap(enterOtpButton);
      await tester.pumpAndSettle();

      // Input OTP dialog should be displayed
      expect(find.byKey(const Key('otp_input_field')), findsOneWidget);
      expect(find.byKey(const Key('take_proof_photo_button')), findsOneWidget);
      expect(find.byKey(const Key('submit_otp_button')), findsOneWidget);
    });
  });
}
