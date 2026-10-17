import 'package:flutter/foundation.dart';

/// Feature flags allowing activation and deactivation of application modules directly in code.
///
/// Modifiez simplement les valeurs statiques ci-dessous pour activer ou désactiver
/// instantanément n'importe quel module dans l'ensemble de l'application (menus,
/// navigation, redirections et garde-fous).
class FeatureFlags {
  FeatureFlags._();

  // ===========================================================================
  // MODULE SWITCHES (Modifiables directement dans le code ou via bootstrap)
  // ===========================================================================
  static bool enableWallet = true;
  static bool enableDocuments = true;
  static bool enableMarketplace = true;
  static bool enableProcedures = false;
  static bool enableChat = true;
  static bool enableCommunity = false;
  static bool enableCommittee = false;
  static bool enableFreelance = false;
  static bool enableServices = true;
  static bool enableProfile = true;
  static bool enableSettings = true;

  /// Met à jour les flags depuis la configuration reçue du serveur.
  static void updateFromRemote(Map<String, dynamic> remoteFlags) {
    if (remoteFlags.containsKey('wallet')) enableWallet = remoteFlags['wallet'] == true;
    if (remoteFlags.containsKey('documents')) enableDocuments = remoteFlags['documents'] == true;
    if (remoteFlags.containsKey('marketplace')) enableMarketplace = remoteFlags['marketplace'] == true;
    if (remoteFlags.containsKey('procedures')) enableProcedures = remoteFlags['procedures'] == true;
    if (remoteFlags.containsKey('chat')) enableChat = remoteFlags['chat'] == true;
    if (remoteFlags.containsKey('community')) enableCommunity = remoteFlags['community'] == true;
    if (remoteFlags.containsKey('committee')) enableCommittee = remoteFlags['committee'] == true;
    if (remoteFlags.containsKey('freelance')) enableFreelance = remoteFlags['freelance'] == true;
    if (remoteFlags.containsKey('services')) enableServices = remoteFlags['services'] == true;
    if (remoteFlags.containsKey('profile')) enableProfile = remoteFlags['profile'] == true;
    if (remoteFlags.containsKey('settings')) enableSettings = remoteFlags['settings'] == true;
  }

  /// Vérifie si l'accès à une route donnée est activé d'après les flags configurés.
  ///
  /// Si le module associé à la route est désactivé, renvoie false pour déclencher
  /// la redirection et empêcher tout accès via l'interface ou lien profond.
  static bool isRouteEnabled(String location) {
    final uri = Uri.tryParse(location);
    final path = uri?.path.toLowerCase() ?? location.toLowerCase();

    if (path.startsWith('/debug/realtime')) {
      return kDebugMode;
    }
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
    if (path.startsWith('/chat') ||
        path.startsWith('/story') ||
        path.startsWith('/contact-profile')) {
      return enableChat;
    }
    if (path.startsWith('/community')) {
      return enableCommunity;
    }
    if (path.startsWith('/committee')) {
      return enableCommittee;
    }
    if (path.startsWith('/freelance') || path.startsWith('/reputation')) {
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
