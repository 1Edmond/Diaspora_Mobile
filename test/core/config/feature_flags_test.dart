import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/core/config/feature_flags.dart';

void main() {
  group('FeatureFlags Tests', () {
    test('Default core flags are booleans', () {
      expect(FeatureFlags.enableWallet, isA<bool>());
      expect(FeatureFlags.enableDocuments, isA<bool>());
      expect(FeatureFlags.enableMarketplace, isA<bool>());
      expect(FeatureFlags.enableProcedures, isA<bool>());
      expect(FeatureFlags.enableChat, isA<bool>());
      expect(FeatureFlags.enableCommunity, isA<bool>());
      expect(FeatureFlags.enableCommittee, isA<bool>());
      expect(FeatureFlags.enableProfile, isA<bool>());
      expect(FeatureFlags.enableSettings, isA<bool>());
    });

    test('isRouteEnabled matches module routes dynamically with flag state', () {
      expect(FeatureFlags.isRouteEnabled('/wallet'), equals(FeatureFlags.enableWallet));
      expect(FeatureFlags.isRouteEnabled('/wallet/send'), equals(FeatureFlags.enableWallet));
      expect(FeatureFlags.isRouteEnabled('/documents'), equals(FeatureFlags.enableDocuments));
      expect(FeatureFlags.isRouteEnabled('/documents/123'), equals(FeatureFlags.enableDocuments));
      expect(FeatureFlags.isRouteEnabled('/marketplace'), equals(FeatureFlags.enableMarketplace));
      expect(FeatureFlags.isRouteEnabled('/procedures'), equals(FeatureFlags.enableProcedures));
      expect(FeatureFlags.isRouteEnabled('/chat'), equals(FeatureFlags.enableChat));
      expect(FeatureFlags.isRouteEnabled('/community'), equals(FeatureFlags.enableCommunity));
      expect(FeatureFlags.isRouteEnabled('/committee'), equals(FeatureFlags.enableCommittee));
      expect(FeatureFlags.isRouteEnabled('/profile'), equals(FeatureFlags.enableProfile));
      expect(FeatureFlags.isRouteEnabled('/settings'), equals(FeatureFlags.enableSettings));

      // Core routes always enabled
      expect(FeatureFlags.isRouteEnabled('/home'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/onboarding'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/auth/login'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/notifications'), isTrue);
    });
  });
}
