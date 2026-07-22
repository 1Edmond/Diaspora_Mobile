# Diaspora — Diaspora Togolaise MVP

Flutter 3.44+ / Dart ^3.7.0 — Clean Architecture + Riverpod + Dio.

## Architecture

**3-layer Clean Architecture** par feature :

```
lib/
├── core/               # Cross-cutting: config, network, theme, DI, SSE, i18n
├── data/mock/          # Mock API stubs (6 modules)
├── features/
│   ├── auth/           # Auth, session, JWT
│   ├── chat/           # Messaging, contacts, calls (Agora)
│   ├── committee/      # Committees, meetings, proposals
│   ├── community/      # Social feed, posts, comments
│   ├── documents/      # Document upload/OCR/verification
│   ├── home/           # Dashboard screen (single file)
│   ├── notifications/  # SSE push, Firebase FCM, local notif
│   ├── procedures/     # Administrative procedures (API-connected)
│   ├── profile/        # Internal/External profile
│   ├── services/       # Service marketplace, reservations
│   ├── settings/       # Theme, locale, privacy
│   └── wallet/         # Virtual wallet, transfers, PIN/biometric
├── shared/
│   ├── presentation/   # Shared providers
│   ├── services/       # StorageService (Hive), NotificationService
│   └── widgets/        # GlassContainer, NeumorphicContainer, PrimaryButton
└── main.dart
```

| Layer | Responsabilité | Contenu |
|-------|----------------|---------|
| `domain/` | Règles métier, pas de dépendance Flutter | `entities/` (POJO), `repositories/` (interfaces), `usecases/` |
| `data/` | Implémentation concrète | `repositories/` (impl), `models/` (JSON serializable), `services/` (HTTP) |
| `presentation/` | UI Flutter | `screens/`, `controllers/` (StateNotifier), `widgets/` |

## Stack

| Domaine | Technologie |
|---------|-------------|
| State | `flutter_riverpod` (StateNotifierProvider, AsyncValue) |
| DI | `get_it` (service locator) |
| Routing | `go_router` (StatefulShellRoute for bottom nav) |
| HTTP | `dio` + `AuthInterceptor` (JWT Bearer, refresh 401) |
| SSE | Custom `SseClient` (Dio streaming) |
| Local storage | `hive` (settings box) |
| Auth | JWT (access + refresh tokens, `flutter_secure_storage`) |
| Theme | Material 3, `ColorScheme.fromSeed`, mode clair/sombre |
| Design | Neumorphism + Glassmorphism, palette drapeau togolais |
| Animations | `flutter_animate` |
| Notifications | Firebase FCM + `flutter_local_notifications` |
| Calls | `agora_rtc_engine` |
| Biometric | `local_auth` |
| QR | `mobile_scanner` + `qr_flutter` |
| OCR | `google_mlkit_text_recognition` |
| PDF | `pdf` + `printing` |

## Networking

Deux pipes HTTP, commutés via `AppConfig.useMockData` (`true` = dev) :

```
useMockData = true  →  DioClient (baseUrl: localhost:3000)
                         └─ _MockInterceptor (router les appels vers lib/data/mock/)
useMockData = false →  SharedDio (baseUrl: ngrok API réelle)
                         └─ AuthInterceptor (Bearer token, refresh 401)
```

- **Auth** (`AuthRepositoryImpl`) : son propre `Dio`, pointe toujours l'API réelle.
- **Shared Dio** (injection.dart:171) : `validateStatus: (_) => true`, interceptors = `AuthInterceptor` + `LogInterceptor` (debug).
- **TokenService** : Hive-backed, cache les tokens, `isAccessTokenExpired` retourne `false` si `expiry` est `null`.
- **PascalCase/camelCase** : tous les `fromJson` gèrent les deux formats (API .NET → serveur réel).

## Routing (GoRouter)

```
/                     → Splash (600ms → /onboarding)
/onboarding           → OnboardingScreen
/auth                 → LoginScreen
/auth/register        → RegisterScreen
/auth/verify?email=&code=  → PhoneVerificationScreen
/home                 → HomeScreen (dashboard)
/profile              → ProfileScreen
/services             → ServicesHomeScreen [bottom nav tab 1]
/services/reservations  → ReservationsScreen [tab 2]
/services/mine        → MyServicesScreen [tab 3]
/services/settings    → ServiceSettingsScreen [tab 4]
/services/create      → CreateServiceScreen
/services/:id         → ServiceDetailScreen
/procedures           → ProceduresListScreen (RefreshIndicator)
/procedures/:id       → ProcedureDetailScreen
/notifications        → NotificationsScreen
/chat                 → ConversationListScreen [bottom nav]
/chat/contacts        → ContactsScreen
/chat/:id             → ChatScreen
/community            → CommunityHomeScreen
/committee            → CommitteeHomeScreen
/documents            → DocumentsListScreen
/wallet               → WalletScreen
/wallet/send          → SendMoneyScreen
/settings             → SettingsScreen
```

## State Management (Riverpod)

Chaque feature expose un `StateNotifierProvider` :

| Provider | State | Usage |
|----------|-------|-------|
| `authNotifierProvider` | `AsyncValue<User?>` | Login, session, fetchInternalProfile |
| `proceduresProvider` | `ProceduresState` | Liste paginée + complétion locale |
| `notificationsStateProvider` | `NotificationsState` | Notifications + SSE |
| `walletNotifierProvider` | `WalletState` | Balance, transactions, transfer |
| `chatNotifierProvider` | `ChatState` | Conversations, messages |
| `communityNotifierProvider` | `CommunityState` | Posts, feed |
| `committeeNotifiersProvider` | `CommitteeState` | Committees, meetings, proposals |
| `servicesNotifierProvider` | `ServicesState` | Service marketplace |
| `settingsNotifierProvider` | `Settings` | Theme, locale, privacy |

Les notifiers utilisent `_ref.read(authNotifierProvider)` pour lire l'utilisateur courant dynamiquement (évite les valeurs obsolètes).

## Design System

**Palette** basée sur le drapeau togolais (`lib/core/theme/design_system.dart`) :

| Rôle | Couleur |
|------|---------|
| Primary | `#0033A0` (Bleu Russe) |
| Secondary | `#006B3F` (Vert) |
| Accent | `#CD0021` (Rouge — CTA) |
| Accent soft | `#FFCE00` (Jaune — badges) |

Composants réutilisables dans `lib/shared/widgets/` :
- `GlassContainer` — arrière-plan flou / translucide
- `NeumorphicContainer` — ombres douces (clair/sombre)
- `PrimaryButton` — full-width, 56px, border-radius 16
- Inputs stylisés

## API Endpoints (API réelle)

```
POST   /auth/register
POST   /auth/verify-email
POST   /auth/login
POST   /auth/refresh-token

GET    /notification/stream (SSE, access_token en query param)
GET    /notifications?pageNumber=&pageSize=&unreadOnly=true
PATCH  /notifications/:id/read

GET    /procedure?profileType=0&profileTypeId=&pageNumber=&pageSize=

GET    /internalprofile/me
```

## Développement

```bash
flutter pub get
flutter run        # mode mock (useMockData = true)
flutter test       # tests unitaires + widget
```

- `AppConfig.useMockData` = `true` → tout le trafic non-auth est intercepté en mémoire (`_MockInterceptor` → `MockApi`).
- `AuthRepositoryImpl` utilise toujours l'API réelle (login, register, refresh).
- Les tokens JWT sont persistés dans Hive (`settings` box).

## Conventions

- **PascalCase** dans les réponses API .NET, camelCase dans le code Dart ; les `fromJson` gèrent les deux.
- **StateNotifier** plutôt que ChangeNotifier.
- **Constructeur** des notifiers = `fetch()` initial ; RefreshIndicator pour le rechargement.
- **`profileType=0`** = profil interne pour les procédures.
- **SSE** : backoff exponentiel 2s→30s, pause en background, reprise au foreground.
- **Pas de commentaires** dans le code Dart (sauf documentation publique).
