# Diaspora — Base de Connaissances (Knowledge Base)

Ce fichier sert de récapitulatif de l'état actuel du projet, des fonctionnalités implémentées, ainsi que des problèmes et bugs connus. Il doit être mis à jour par tout développeur ou agent IA travaillant sur le projet.

## 🌟 Fonctionnalités Implémentées

Le projet est une application Flutter (Clean Architecture, Riverpod, Dio) structurée par "features".

1.  **Auth** : Authentification par JWT, gestion de session et jetons.
2.  **Documents** (✅ 100% Terminé) : Téléchargement, gestion, recherche, catégorisation, suivi d'expiration, et extraction OCR (Google ML Kit) des documents de l'utilisateur. Mise en cache hors-ligne avec Hive.
3.  **Chat** : Messagerie, contacts, appels (via Agora).
4.  **Committee** : Gestion des comités, réunions, et propositions.
5.  **Community** : Fil d'actualité social, posts, et commentaires.
6.  **Notifications** : Notifications via SSE (Server-Sent Events), Firebase FCM et notifications locales.
7.  **Procedures** : Démarches administratives connectées à l'API.
8.  **Profile** : Profils internes et externes.
9.  **Services** : Place de marché pour services et réservations.
10. **Settings** : Gestion du thème (clair/sombre), des langues, et de la confidentialité.
11. **Wallet** : Portefeuille virtuel, transferts, sécurité par code PIN / biométrie.

## 🐞 Problèmes et Bugs Connus

Suite à l'analyse statique du code (Dart Analyzer), plusieurs problèmes nécessitent une attention particulière :

### 1. Erreurs Critiques (Wallet Feature & Tests)
*   **`IWalletRepository`** : Les méthodes `getBalance` et `transfer` ne sont pas définies dans l'interface, ce qui casse la compilation dans `wallet_notifier.dart` et `wallet_transfer_test.dart`.
*   **`_FakeRepo` (Tests du Wallet)** : Il manque des implémentations concrètes pour `exchangeCurrency`, `getBalances`, et `sendMoney` dans `wallet_notifier_pin_guard_test.dart`. De plus, la signature de `getTransactions` dans le faux repository ne correspond pas à l'interface `IWalletRepository`.
*   **`AuthNotifier` (Tests Auth)** : L'entité ou la fonction `AuthNotifier` n'est pas trouvée dans `auth_notifier_test.dart`.

### 2. Avertissements de Code (Lints)
*   **Conventions de nommage (Enums)** : De nombreuses constantes et valeurs d'énumérations utilisent le format `MAJUSCULE` (ex: `PENDING`, `COMPLETED`, `VISA`, `PASSPORT`) au lieu du format `lowerCamelCase` recommandé par Dart. Ces avertissements touchent principalement :
    *   `lib/core/constants/enums.dart`
    *   `lib/features/procedures/domain/entities/procedure.dart`
    *   `lib/features/procedures/domain/entities/required_document.dart`
    *   `lib/features/services/domain/entities/service.dart`
*   **Imports Inutilisés** : Certains imports ne sont pas utilisés, par exemple dans `lib/features/procedures/domain/entities/task.dart` (`task_location.dart` et `required_document.dart`).

## 🏗️ Architecture et Normes
*   **Architecture** : 3-layer Clean Architecture (Domain, Data, Presentation) isolée par feature.
*   **API** : Utilisation d'une Mock API (activée via `AppConfig.useMockData = true`) pour le développement hors Auth.
*   **Style** : Neumorphism + Glassmorphism avec les couleurs du drapeau togolais.
*   **Règle de code** : Le code JSON d'API utilise PascalCase, mais l'app Dart utilise camelCase (les méthodes `fromJson` gèrent les deux). Pas de commentaires dans le code Dart sauf pour la documentation publique.
