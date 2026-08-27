class AppConfig {
  // SWITCH: true = use mock data for non-auth endpoints, false = use real backend everywhere
  static const bool useMockData = true;

  static const String _localApiUrl = 'http://localhost:3000/api';
  static const String _prodApiUrl =
      'https://8f42-194-71-130-44.ngrok-free.app/api';

  static const String apiBaseUrl = useMockData ? _localApiUrl : _prodApiUrl;
  static const String realApiBaseUrl = _prodApiUrl;

  static const String clientKey = 'ClientKeyFromClientFlutterApp';

  static const appName = 'Diaspora';
  static const defaultLocale = 'fr';
}
