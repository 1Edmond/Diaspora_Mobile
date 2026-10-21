class AppConfig {
  // SWITCH: true = use mock data for non-auth endpoints, false = use real backend everywhere
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );

  static const String _localApiUrl = 'http://localhost:3000/api';
  static const String _prodApiUrl =
      'https://7bbd-194-71-130-44.ngrok-free.app/api';

  static const String apiBaseUrl = useMockData ? _localApiUrl : _prodApiUrl;
  static const String realApiBaseUrl = _prodApiUrl;

  static const String clientKey = 'ClientKeyFromClientFlutterApp';

  static const appName = 'Diaspora';
  static const defaultLocale = 'fr';
  static String parcelTransportCategoryId =
      '019248a0-6b3a-7182-9a84-7c6d9e0f1234';
  static List<String> supportedLocales = ['fr', 'en', 'ru'];
  static String? currentProfileTypeId;
}
