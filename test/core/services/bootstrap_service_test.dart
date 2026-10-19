import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:diaspora_app/core/config/app_config.dart';
import 'package:diaspora_app/core/config/feature_flags.dart';
import 'package:diaspora_app/core/network/dio_client.dart';
import 'package:diaspora_app/core/services/bootstrap_service.dart';

void main() {
  setUp(() {
    GetIt.instance.reset();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  test('BootstrapService applies remote feature flags and parcelTransportCategoryId', () async {
    final client = DioClient(useMockData: true);
    GetIt.instance.registerSingleton<DioClient>(client);

    await BootstrapService.initialize();

    expect(AppConfig.parcelTransportCategoryId, '019248a0-6b3a-7182-9a84-7c6d9e0f1234');
    expect(FeatureFlags.enableWallet, isTrue);
    expect(FeatureFlags.enableMarketplace, isTrue);
    expect(FeatureFlags.enableDocuments, isTrue);
    expect(FeatureFlags.enableProcedures, isFalse);
    expect(FeatureFlags.enableFreelance, isFalse);
  });

  test('BootstrapService sends profileTypeId and updates feature flags dynamically', () async {
    final client = DioClient(useMockData: true);
    GetIt.instance.registerSingleton<DioClient>(client);

    expect(FeatureFlags.enableFreelance, isFalse);

    await BootstrapService.initialize(profileTypeId: 'freelance-provider-type', countryCode: 'TG');

    expect(FeatureFlags.enableFreelance, isTrue);

    // Test resetToDefault
    FeatureFlags.resetToDefault();
    expect(FeatureFlags.enableFreelance, isFalse);
  });
}
