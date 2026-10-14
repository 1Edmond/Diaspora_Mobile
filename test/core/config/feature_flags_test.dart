import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_app/core/config/feature_flags.dart';

void main() {
  group('FeatureFlags Tests', () {
    test('Default flag states are enabled', () {
      expect(FeatureFlags.enableWallet, isTrue);
      expect(FeatureFlags.enableDocuments, isTrue);
      expect(FeatureFlags.enableMarketplace, isTrue);
      expect(FeatureFlags.enableProcedures, isTrue);
      expect(FeatureFlags.enableChat, isTrue);
      expect(FeatureFlags.enableCommunity, isTrue);
      expect(FeatureFlags.enableCommittee, isTrue);
      expect(FeatureFlags.enableProfile, isTrue);
      expect(FeatureFlags.enableSettings, isTrue);
    });

    test('isRouteEnabled matches module routes correctly', () {
      expect(FeatureFlags.isRouteEnabled('/wallet'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/wallet/send'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/documents'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/documents/123'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/marketplace'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/procedures'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/chat'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/story/view'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/community'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/committee'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/profile'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/settings'), isTrue);

      // Core routes always enabled
      expect(FeatureFlags.isRouteEnabled('/home'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/onboarding'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/auth/login'), isTrue);
      expect(FeatureFlags.isRouteEnabled('/notifications'), isTrue);
    });
  });
}
