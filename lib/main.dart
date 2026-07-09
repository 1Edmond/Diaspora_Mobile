import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/routes.dart';
import 'core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/notifications/data/services/firebase_messaging_service.dart';
import 'features/documents/data/local_storage/document_local_storage.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase if configured.
  try {
    // If you haven't run `flutterfire configure`, this will fail gracefully
    // and the app will continue using mock services.
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      'Firebase: Not initialized. This is expected if google-services.json is missing. '
      'Falling back to mock services. Error: $e',
    );
  }

  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Initialize local document storage
  await DocumentLocalStorage.initialize();

  configureDependencies();

  // Initialize Firebase Messaging after dependency injection if Firebase is available
  final firebaseMessagingService = getIt<FirebaseMessagingService>();
  if (Firebase.apps.isNotEmpty) {
    await firebaseMessagingService.initialize();
  } else {
    debugPrint(
      'Skipping Firebase Messaging init because Firebase is not configured',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.router(ref);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Diaspora',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
