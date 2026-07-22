import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/auth_interceptor.dart';
import '../network/token_service.dart';
import '../../features/notifications/data/services/notification_rest_service.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';

// Wallet PIN/biometric service
import '../../features/wallet/domain/wallet_auth_service.dart';
import '../../features/wallet/data/wallet_auth_service_impl.dart';

import '../../shared/services/notification_service.dart';

// Notifications
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/data/services/firebase_messaging_service.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/fetch_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read.dart';
import '../../features/notifications/domain/usecases/save_notification.dart';

import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';

import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/get_posts.dart';
import '../../features/community/domain/usecases/get_post_by_id.dart';
import '../../features/community/domain/usecases/create_post.dart';
import '../../features/community/domain/usecases/like_post.dart';
import '../../features/community/domain/usecases/get_comments.dart';
import '../../features/community/domain/usecases/create_comment.dart';

import '../../features/committee/data/repositories/committee_repository_impl.dart';
import '../../features/committee/domain/repositories/committee_repository.dart';

// Documents
import '../../features/documents/data/repositories/document_repository_impl.dart';
import '../../features/documents/data/repositories/document_type_repository_impl.dart';
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/documents/domain/repositories/document_type_repository.dart';

// Profile
import '../../features/profile/data/services/profile_service.dart';

// Procedures
import '../../features/procedures/data/services/procedure_service.dart';

// Settings
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../realtime/mock_realtime_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // Register low-level utilities
  getIt.registerSingleton<DioClient>(DioClient());

  // Shared Dio for the real API with automatic token injection.
  // Auth endpoints (login/register/verify) do NOT need a token,
  // but the interceptor gracefully skips when no token exists yet.
  getIt.registerSingleton<Dio>(_createRealApiDio());

  // Mock realtime service for development
  getIt.registerSingleton<MockRealtimeService>(MockRealtimeService());

  // Auth repository — uses its own Dio pointing to the real API.
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // Profile service — fetches internal profile data from the real API.
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());

  // Procedure service — fetches procedures from the real API.
  getIt.registerLazySingleton<ProcedureService>(() => ProcedureService());

  // Services repository — now registered against its interface and backed by DioClient.
  getIt.registerLazySingleton<IServiceRepository>(
    () => ServiceRepositoryImpl(),
  );

  // Wallet repository (DioClient-backed; mocked endpoints available in MockApi)
  getIt.registerLazySingleton<IWalletRepository>(() => WalletRepositoryImpl());

  // Wallet PIN / biometric helper (used by WalletNotifier to guard transfers)
  getIt.registerLazySingleton<IWalletAuthService>(
    () => WalletAuthServiceImpl(),
  );

  // In-app notification service (dev/test)
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Notifications feature
  getIt.registerLazySingleton<NotificationRestService>(
    () => NotificationRestService(),
  );
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      restService: getIt<NotificationRestService>(),
    ),
  );
  getIt.registerLazySingleton<FetchNotificationsUseCase>(
    () => FetchNotificationsUseCase(getIt<INotificationRepository>()),
  );
  getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(getIt<INotificationRepository>()),
  );
  getIt.registerLazySingleton<SaveNotificationUseCase>(
    () => SaveNotificationUseCase(getIt<INotificationRepository>()),
  );

  // Chat feature
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(client: getIt<DioClient>()),
  );

  // Community feature
  getIt.registerLazySingleton<ICommunityRepository>(
    () => CommunityRepositoryImpl(),
  );
  getIt.registerLazySingleton<GetPostsUseCase>(
    () => GetPostsUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<GetPostByIdUseCase>(
    () => GetPostByIdUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<LikePostUseCase>(
    () => LikePostUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<UnlikePostUseCase>(
    () => UnlikePostUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<GetCommentsUseCase>(
    () => GetCommentsUseCase(getIt<ICommunityRepository>()),
  );
  getIt.registerLazySingleton<CreateCommentUseCase>(
    () => CreateCommentUseCase(getIt<ICommunityRepository>()),
  );

  // Committee feature
  getIt.registerLazySingleton<ICommitteeRepository>(
    () => CommitteeRepositoryImpl(),
  );

  // Documents feature
  getIt.registerLazySingleton<IDocumentRepository>(
    () => DocumentRepositoryImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<IDocumentTypeRepository>(
    () => DocumentTypeRepositoryImpl(dio: getIt<Dio>()),
  );

  // Settings feature
  getIt.registerLazySingleton<ISettingsRepository>(
    () => SettingsRepositoryImpl(settingsBox: Hive.box('settings')),
  );
}

Dio _createRealApiDio() {
  final tokenService = TokenService();
  // Separate Dio for refresh calls to avoid infinite loop with AuthInterceptor
  final refreshDio = Dio(BaseOptions(
    baseUrl: AppConfig.realApiBaseUrl,
    headers: {
      'Content-Type': 'application/json',
      'x-client-key': AppConfig.clientKey,
    },
  ));
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.realApiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (_) => true,
    headers: {
      'Content-Type': 'application/json',
      'x-client-key': AppConfig.clientKey,
    },
  ));
  dio.interceptors.addAll([
    AuthInterceptor(tokenService, refreshDio),
    if (kDebugMode)
      LogInterceptor(requestBody: true, responseBody: true),
  ]);
  return dio;
}
