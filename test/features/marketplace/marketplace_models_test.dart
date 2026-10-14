import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/features/marketplace/data/models/listing_model.dart';
import 'package:diaspora_app/features/marketplace/data/models/listing_summary_model.dart';
import 'package:diaspora_app/features/marketplace/data/models/service_request_model.dart';
import 'package:diaspora_app/features/marketplace/domain/entities/enums.dart';
import 'package:diaspora_app/features/profile/data/models/public_profile_type_model.dart';

void main() {
  group('Marketplace Models Tests (Phase P6)', () {
    test('ListingModel parses providerProfileId, providerIsVerified and providerCountryCode', () {
      final json = {
        'id': 'listing-123',
        'title': 'Traduction Assermentee',
        'description': 'Service de traduction',
        'category': 'Traduction',
        'subCategory': 'Documents',
        'price': 15000.0,
        'currency': 'XOF',
        'priceType': 'Fixed',
        'images': <String>[],
        'country': 'TG',
        'city': 'Lome',
        'providerId': 'provider-user-456',
        'providerProfileId': 'profile-guid-789',
        'providerName': 'Koffi Mensah',
        'providerIsVerified': true,
        'providerCountryCode': 'TG',
        'rating': 4.8,
        'reviewsCount': 12,
        'createdAt': '2026-03-01T10:00:00Z',
      };

      final model = ListingModel.fromJson(json);

      expect(model.id, equals('listing-123'));
      expect(model.providerProfileId, equals('profile-guid-789'));
      expect(model.providerIsVerified, isTrue);
      expect(model.providerCountryCode, equals('TG'));
      expect(model.price, equals(15000.0));
    });

    test('ListingSummaryModel parses providerProfileId and providerIsVerified', () {
      final json = {
        'id': 'sum-1',
        'title': 'Aide administrative',
        'price': 25000.0,
        'currency': 'XOF',
        'category': 'Admin',
        'country': 'CI',
        'city': 'Abidjan',
        'providerId': 'user-1',
        'providerProfileId': 'prof-ci-1',
        'providerName': 'Aya',
        'providerIsVerified': true,
        'providerCountryCode': 'CI',
        'rating': 5.0,
        'reviewsCount': 3,
      };

      final summary = ListingSummaryModel.fromJson(json);

      expect(summary.providerProfileId, equals('prof-ci-1'));
      expect(summary.providerIsVerified, isTrue);
      expect(summary.providerCountryCode, equals('CI'));
    });

    test('ServiceRequestModel correctly computes canPay, isHeld, and status transitions', () {
      final pendingPaymentJson = {
        'id': 'req-1',
        'listingId': 'list-1',
        'listingTitle': 'Transport Dakar',
        'requesterId': 'req-user-1',
        'providerId': 'prov-user-1',
        'status': 'Accepted',
        'paymentStatus': 'Pending',
        'agreedPrice': 50000.0,
        'currency': 'XOF',
        'notes': 'Urgent',
        'createdAt': '2026-03-10T12:00:00Z',
      };

      final model = ServiceRequestModel.fromJson(pendingPaymentJson);

      expect(model.status, equals(ServiceRequestStatus.accepted));
      expect(model.paymentStatus, equals(PaymentStatus.pending));
      expect(model.canPay, isTrue);
      expect(model.isHeld, isFalse);

      final heldPaymentJson = {
        'id': 'req-2',
        'listingId': 'list-1',
        'listingTitle': 'Transport Dakar',
        'requesterId': 'req-user-1',
        'providerId': 'prov-user-1',
        'status': 1, // accepted
        'paymentStatus': 3, // held
        'agreedPrice': 50000.0,
        'currency': 'XOF',
        'createdAt': '2026-03-10T12:00:00Z',
      };

      final heldModel = ServiceRequestModel.fromJson(heldPaymentJson);

      expect(heldModel.paymentStatus, equals(PaymentStatus.held));
      expect(heldModel.isHeld, isTrue);
      expect(heldModel.canPay, isFalse);
    });

    test('PublicProfileType parses all multi-country fields', () {
      final json = {
        'id': 'type-tg',
        'countryCode': 'TG',
        'countryName': 'Togo',
        'currency': 'XOF',
        'phoneIndicatif': '+228',
        'flag': '🇹🇬',
      };

      final profileType = PublicProfileType.fromJson(json);

      expect(profileType.id, equals('type-tg'));
      expect(profileType.countryCode, equals('TG'));
      expect(profileType.currency, equals('XOF'));
      expect(profileType.phoneIndicatif, equals('+228'));
      expect(profileType.flag, equals('🇹🇬'));
    });
  });
}
