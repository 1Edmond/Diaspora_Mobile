import 'dart:async';
import 'package:diaspora_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/procedures/presentation/screens/procedures_list_screen.dart';
import '../../features/procedures/presentation/screens/procedure_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/services/presentation/screens/services_home_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/services/presentation/screens/create_service_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/chat/presentation/screens/create_conversation_screen.dart';
import '../../features/chat/presentation/screens/select_contacts_screen.dart';

import '../../features/community/presentation/screens/community_home_screen.dart';
import '../../features/community/presentation/screens/post_detail_screen.dart';
import '../../features/community/presentation/screens/create_post_screen.dart';

import '../../features/committee/presentation/screens/committee_home_screen.dart';
import '../../features/committee/presentation/screens/members_screen.dart';
import '../../features/committee/presentation/screens/meetings_screen.dart';
import '../../features/committee/presentation/screens/proposals_screen.dart';

import '../../features/documents/presentation/screens/documents_list_screen.dart';
import '../../features/documents/presentation/screens/document_detail_screen.dart';
import '../../features/documents/presentation/screens/upload_document_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/providers_config_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/send_money_screen.dart';
import '../realtime/realtime_debug_screen.dart';

class AppRouter {
  static GoRouter router(WidgetRef ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPlaceholder()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(
        path: '/auth',
        builder: (c, s) => const LoginScreen(),
        routes: [
          GoRoute(path: 'login', builder: (c, s) => const LoginScreen()),
          GoRoute(path: 'register', builder: (c, s) => const RegisterScreen()),
          GoRoute(
            path: 'verify',
            builder: (c, s) => const PhoneVerificationScreen(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(
        path: '/profile',
        builder: (c, s) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'create-external',
            builder: (c, s) => const SizedBox.shrink(),
          ),
        ],
      ),
      GoRoute(
        path: '/services',
        builder: (c, s) => const ServicesHomeScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder:
                (c, s) =>
                    ServiceDetailScreen(serviceId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'create',
            builder: (c, s) => const CreateServiceScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/procedures',
        builder: (c, s) => const ProceduresListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder:
                (c, s) =>
                    ProcedureDetailScreen(procedureId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (c, s) => const ConversationListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (c, s) => const CreateConversationScreen(),
          ),
          GoRoute(
            path: 'select-contacts',
            builder: (c, s) => const SelectContactsScreen(),
          ),
          GoRoute(
            path: ':id',
            builder:
                (c, s) => ChatScreen(conversationId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/community',
        builder: (c, s) => const CommunityHomeScreen(),
        routes: [
          GoRoute(
            path: 'post/:id',
            builder:
                (c, s) => PostDetailScreen(postId: s.pathParameters['id']!),
          ),
          GoRoute(path: 'create', builder: (c, s) => const CreatePostScreen()),
        ],
      ),
      GoRoute(
        path: '/committee',
        builder: (c, s) => const CommitteeHomeScreen(),
        routes: [
          GoRoute(
            path: ':id/members',
            builder:
                (c, s) => MembersScreen(committeeId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: ':id/meetings',
            builder:
                (c, s) => MeetingsScreen(committeeId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: ':id/proposals',
            builder:
                (c, s) => ProposalsScreen(committeeId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/documents',
        builder: (c, s) => const DocumentsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder:
                (c, s) =>
                    DocumentDetailScreen(documentId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'upload',
            builder: (c, s) => const UploadDocumentScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (c, s) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'providers',
            builder: (c, s) => const ProvidersConfigScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/wallet',
        builder: (c, s) => const WalletScreen(),
        routes: [
          GoRoute(path: 'send', builder: (c, s) => const SendMoneyScreen()),
        ],
      ),
      GoRoute(
        path: '/debug/realtime',
        builder: (c, s) => const RealtimeDebugScreen(),
      ),
    ],
  );
}

class SplashPlaceholder extends StatefulWidget {
  const SplashPlaceholder({super.key});

  @override
  State<SplashPlaceholder> createState() => _SplashPlaceholderState();
}

class _SplashPlaceholderState extends State<SplashPlaceholder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) GoRouter.of(context).go('/onboarding');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Diaspora — loading...')));
  }
}
