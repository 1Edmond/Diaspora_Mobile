class AppConfig {
  // SWITCH: true = use mock data, false = use real backend
  static const bool useMockData = true;

  static const String _localApiUrl = 'http://localhost:3000/api';
  static const String _prodApiUrl = 'https://api.diaspora-togo.com';

  static const String apiBaseUrl = useMockData ? _localApiUrl : _prodApiUrl;

  static const appName = 'Diaspora';
  static const defaultLocale = 'fr';
}
