import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'core/deep_link/deep_link_service.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/routes.dart';
import 'core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/presentation/controllers/auth_notifier.dart';
import 'features/notifications/data/services/firebase_messaging_service.dart';
import 'features/notifications/presentation/providers/sse_provider.dart';
import 'features/notifications/presentation/providers/notifications_providers.dart';
import 'features/documents/data/local_storage/document_local_storage.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase: Not initialized. This is expected if google-services.json is missing. '
      'Falling back to mock services. Error: $e',
    );
  }

  await Hive.initFlutter();
  await Hive.openBox('settings');

  await DocumentLocalStorage.initialize();

  configureDependencies();

  final firebaseMessagingService = getIt<FirebaseMessagingService>();
  if (Firebase.apps.isNotEmpty) {
    await firebaseMessagingService.initialize();
  } else {
    debugPrint(
      'Skipping Firebase Messaging init because Firebase is not configured',
    );
  }

  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  getIt.registerSingleton<DeepLinkService>(deepLinkService);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _deepLinkSub;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final service = getIt<DeepLinkService>();

    final initial = service.initialUri;
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleDeepLink(initial);
      });
    }

    _deepLinkSub = service.uriStream.listen((uri) {
      if (mounted) _handleDeepLink(uri);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authNotifierProvider.notifier).restoreSession();
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'diasporaapp' || uri.host != 'verify-email') return;
    final email = uri.queryParameters['email'];
    final code = uri.queryParameters['code'];
    if (email != null && code != null) {
      _router?.go(
        '/auth/verify',
        extra: <String, String>{'email': email, 'code': code},
      );
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(sseConnectionProvider.notifier).resume();
        final user = ref.read(authNotifierProvider).valueOrNull;
        final target = user?.id;
        if (target != null) {
          ref
              .read(notificationsStateProvider.notifier)
              .fetchNotifications(target);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        ref.read(sseConnectionProvider.notifier).pause();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _router = AppRouter.router(ref);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Diaspora',
      debugShowCheckedModeBanner: false,
      routerConfig: _router!,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('ru'), Locale('en')],
      locale: const Locale('fr'),
    );
  }
}
