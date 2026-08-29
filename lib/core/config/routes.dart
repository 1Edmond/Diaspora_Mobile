import 'dart:async';
import 'package:diaspora_app/features/settings/presentation/screens/providers_config_screen.dart';
import 'package:diaspora_app/features/wallet/presentation/screens/send_money_screen.dart';
import 'package:diaspora_app/features/wallet/presentation/screens/wallet_screen.dart';
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
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/chat/presentation/screens/chat_shell.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/contact_profile_screen.dart';
import '../../features/chat/presentation/screens/contacts_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/chat/presentation/screens/create_conversation_screen.dart';
import '../../features/chat/presentation/screens/select_contacts_screen.dart';
import '../../features/chat/presentation/screens/chat_profile_screen.dart';
import '../../features/chat/presentation/screens/story_viewer_screen.dart';
import '../../features/chat/presentation/screens/add_story_screen.dart';
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
import '../../features/marketplace/presentation/screens/marketplace_shell.dart';
import '../../features/marketplace/presentation/screens/marketplace_home_screen.dart';
import '../../features/marketplace/presentation/screens/favorites_screen.dart';
import '../../features/marketplace/presentation/screens/my_listings_screen.dart';
import '../../features/marketplace/presentation/screens/provider_dashboard_screen.dart';
import '../../features/marketplace/presentation/screens/create_listing_wizard_screen.dart';
import '../../features/marketplace/presentation/screens/listing_detail_screen.dart';
import '../../features/marketplace/presentation/screens/request_service_screen.dart';
import '../../features/marketplace/presentation/screens/my_requests_screen.dart';
import '../../features/freelance/presentation/screens/freelance_shell.dart';
import '../../features/freelance/presentation/screens/freelance_home_screen.dart';
import '../../features/freelance/presentation/screens/job_posting_detail_screen.dart';
import '../../features/freelance/presentation/screens/my_applications_screen.dart';
import '../../features/freelance/presentation/screens/my_offers_screen.dart';
import '../../features/freelance/presentation/screens/job_applications_screen.dart';
import '../../features/freelance/presentation/screens/create_job_posting_screen.dart';
import '../../features/freelance/presentation/screens/check_in_screen.dart';
import '../../features/freelance/presentation/screens/job_preferences_screen.dart';
import '../../features/freelance/presentation/screens/job_templates_screen.dart';
import '../../features/freelance/presentation/screens/reputation_screen.dart';
import '../../features/freelance/domain/entities/enums.dart';

import '../realtime/realtime_debug_screen.dart';
import '../../features/auth/presentation/controllers/pending_verification_provider.dart';
import '../../features/profile/presentation/screens/profile_list_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(WidgetRef ref) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final pending = ref.read(pendingVerificationEmailProvider);
      if (pending != null && !state.matchedLocation.startsWith('/auth')) {
        return '/auth/verify';
      }
      return null;
    },
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
            builder: (c, s) {
              final extra = s.extra;
              final email =
                  extra is String
                      ? extra
                      : (extra as Map?)?['email'] as String?;
              final code = (extra is Map ? extra['code'] : null) as String?;
              return PhoneVerificationScreen(email: email, code: code);
            },
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/profiles', builder: (c, s) => const ProfileListScreen()),
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
      StatefulShellRoute.indexedStack(
        builder:
            (c, s, navigationShell) =>
                ChatShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (c, s) => const ConversationListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat/contacts',
                builder: (c, s) => const ContactsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat/settings',
                builder: (c, s) => const SettingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat/profile',
                builder: (c, s) => const ChatProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Chat sub-routes (pushed on root navigator — full-screen, bottom nav hidden)
      // Specific routes must come BEFORE parameterized /chat/:id
      GoRoute(
        path: '/chat/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const CreateConversationScreen(),
      ),
      GoRoute(
        path: '/chat/select-contacts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const SelectContactsScreen(),
      ),
      GoRoute(
        path: '/story/view',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (c, s) => StoryViewerScreen(storyName: s.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/story/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => const AddStoryScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (c, s) => ChatScreen(conversationId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/contact-profile/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (c, s) => ContactProfileScreen(
              contactId: s.pathParameters['id']!,
              contactName: s.extra as String?,
            ),
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
            path: 'upload',
            builder: (c, s) => const UploadDocumentScreen(),
          ),
          GoRoute(
            path: ':id',
            builder:
                (c, s) =>
                    DocumentDetailScreen(documentId: s.pathParameters['id']!),
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
      // Marketplace routes - StatefulShellRoute for bottom nav
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                MarketplaceShell(navigationShell: navigationShell),
        branches: [
          // Branch 0: Home/Explorer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (context, state) => const MarketplaceHomeScreen(),
              ),
            ],
          ),
          // Branch 1: Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          // Branch 2: My Listings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace/mine',
                builder: (context, state) => const MyListingsScreen(),
              ),
            ],
          ),
          // Branch 3: Provider Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace/provider-dashboard',
                builder: (context, state) => const ProviderDashboardScreen(),
              ),
            ],
          ),
        ],
      ),
      // Marketplace leaf routes (pushed on root navigator - full screen, bottom nav hidden)
      GoRoute(
        path: '/marketplace/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateListingWizardScreen(),
      ),
      // Literal "/request" segment must be declared BEFORE the generic
      // "/marketplace/:id" route, otherwise GoRouter matches "request" as
      // an ":id" and this sub-path is never reachable.
      GoRoute(
        path: '/marketplace/request/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (context, state) =>
                RequestServiceScreen(listingId: state.pathParameters['id']!),
      ),
      // Literal "/requests" segment must be declared BEFORE the generic
      // "/marketplace/:id" route.
      GoRoute(
        path: '/marketplace/requests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyRequestsScreen(),
      ),
      GoRoute(
        path: '/marketplace/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (context, state) =>
                ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/marketplace/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (context, state) =>
                CreateListingWizardScreen(editListingId: state.pathParameters['id']!),
      ),
      // Freelance routes - StatefulShellRoute for bottom nav
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, navigationShell) =>
                FreelanceShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelance',
                builder: (context, state) => const FreelanceHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelance/my-applications',
                builder: (context, state) => const MyApplicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelance/my-offers',
                builder: (context, state) => const MyOffersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelance/preferences',
                builder: (context, state) => const JobPreferencesScreen(),
              ),
            ],
          ),
        ],
      ),
      // Freelance leaf routes (full screen, pushed on root navigator)
      GoRoute(
        path: '/freelance/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateJobPostingScreen(),
      ),
      GoRoute(
        path: '/freelance/templates',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JobTemplatesScreen(),
      ),
      GoRoute(
        path: '/freelance/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (context, state) =>
                JobPostingDetailScreen(jobPostingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/freelance/:id/applications',
        parentNavigatorKey: _rootNavigatorKey,
        builder:
            (context, state) =>
                JobApplicationsScreen(jobPostingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/freelance/check-in/:applicationId/:method',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CheckInScreen(
          applicationId: state.pathParameters['applicationId']!,
          method: CheckInMethod.values[
              int.tryParse(state.pathParameters['method'] ?? '') ??
                  0],
        ),
      ),
      GoRoute(
        path: '/reputation/:subjectId/:role',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ReputationScreen(
          subjectId: state.pathParameters['subjectId']!,
          role: ReputationRole.values[
              int.tryParse(state.pathParameters['role'] ?? '') ?? 0],
        ),
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
