/// Feature flags allowing activation and deactivation of application modules directly in code.
///
/// Modifiez simplement les valeurs statiques ci-dessous pour activer ou désactiver
/// instantanément n'importe quel module dans l'ensemble de l'application (menus,
/// navigation, redirections et garde-fous).
class FeatureFlags {
  FeatureFlags._();

  // ===========================================================================
  // MODULE SWITCHES (Modifiables directement dans le code)
  // ===========================================================================
  static const bool enableWallet = true;
  static const bool enableDocuments = true;
  static const bool enableMarketplace = true;
  static const bool enableProcedures = true;
  static const bool enableChat = true;
  static const bool enableCommunity = true;
  static const bool enableCommittee = true;
  static const bool enableFreelance = true;
  static const bool enableServices = true;
  static const bool enableProfile = true;
  static const bool enableSettings = true;

  /// Vérifie si l'accès à une route donnée est activé d'après les flags configurés.
  ///
  /// Si le module associé à la route est désactivé, renvoie false pour déclencher
  /// la redirection et empêcher tout accès via l'interface ou lien profond.
  static bool isRouteEnabled(String location) {
    final uri = Uri.tryParse(location);
    final path = uri?.path.toLowerCase() ?? location.toLowerCase();

    if (path.startsWith('/wallet')) {
      return enableWallet;
    }
    if (path.startsWith('/documents')) {
      return enableDocuments;
    }
    if (path.startsWith('/marketplace')) {
      return enableMarketplace;
    }
    if (path.startsWith('/procedures')) {
      return enableProcedures;
    }
    if (path.startsWith('/chat') || path.startsWith('/story')) {
      return enableChat;
    }
    if (path.startsWith('/community')) {
      return enableCommunity;
    }
    if (path.startsWith('/committee')) {
      return enableCommittee;
    }
    if (path.startsWith('/freelance')) {
      return enableFreelance;
    }
    if (path.startsWith('/services')) {
      return enableServices;
    }
    if (path.startsWith('/profile')) {
      return enableProfile;
    }
    if (path.startsWith('/settings')) {
      return enableSettings;
    }

    // Les routes d'authentification, d'onboarding, accueil et notifications
    // restent toujours activées.
    return true;
  }
}
