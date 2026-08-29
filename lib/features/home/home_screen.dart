import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/containers/glass_container.dart';
import '../../shared/widgets/containers/neumorphic_container.dart';
import '../../shared/widgets/orbital_fab/orbital_data.dart';
import '../../shared/widgets/orbital_fab/orbital_fab.dart';
import '../community/presentation/controllers/community_notifier.dart';
import '../committee/presentation/controllers/committee_notifiers.dart';
import '../procedures/presentation/controllers/procedures_notifier.dart';
import '../profile/presentation/controllers/profile_providers.dart';
import '../profile/presentation/widgets/profile_switcher_header.dart';
import '../auth/presentation/controllers/auth_notifier.dart';

String initialOf(String value) =>
    value.isNotEmpty ? value[0].toUpperCase() : '?';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime? _lastBackPress;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCompact = false;

  // Threshold in pixels after which the switcher header collapses into
  // its compact form (matches the "version compacte (scroll)" state).
  static const double _compactScrollThreshold = 40;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldBeCompact = _scrollController.offset > _compactScrollThreshold;
    if (shouldBeCompact != _isHeaderCompact) {
      setState(() => _isHeaderCompact = shouldBeCompact);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleBackPress() async {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appuyez encore pour quitter'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Re-fetch profiles if none are available
                  final activeProfile = ref.read(activeProfileProvider);
                  if (activeProfile == null) {
                    await ref.read(authNotifierProvider.notifier).fetchProfiles();
                  }
                  await ref
                      .read(communityNotifierProvider.notifier)
                      .loadPosts(refresh: true);
                  await ref.read(proceduresProvider.notifier).fetch();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: ProfileSwitcherHeader(
                          isCompact: _isHeaderCompact,
                          onNotificationTap: () => context.push('/notifications'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: 'Services rapides'),
                            SizedBox(height: 16),
                            _MenuGridSection(),
                            SizedBox(height: 32),
                            _SectionHeader(title: 'Actualités Communauté'),
                            SizedBox(height: 16),
                            _CommunityFeedSection(),
                            SizedBox(height: 32),
                            _SectionHeader(title: 'Vos Démarches'),
                            SizedBox(height: 16),
                            _ProceduresHighlightSection(),
                            SizedBox(height: 32),
                            _SectionHeader(title: 'Comités Actifs'),
                            SizedBox(height: 16),
                            _CommitteeListSection(),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: _buildOrbitalFab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildOrbitalFab() {
    return OrbitalFab(
      items: [
        OrbitalItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Portefeuille',
          color: AppColors.primary,
          description: 'Gérez votre portefeuille et vos transactions',
          onTap: () => context.push('/wallet'),
        ),
        OrbitalItem(
          icon: Icons.description_rounded,
          label: 'Documents',
          color: AppColors.secondary,
          description: 'Ajoutez et consultez vos documents administratifs',
          onTap: () => context.push('/documents'),
        ),
        OrbitalItem(
          icon: Icons.storefront_rounded,
          label: 'Marketplace',
          color: AppColors.accent,
          description: 'Découvrez services et annonces de la diaspora',
          onTap: () => context.push('/marketplace'),
        ),
        OrbitalItem(
          icon: Icons.fact_check_rounded,
          label: 'Démarches',
          color: const Color(0xFF8B5CF6),
          description: 'Accédez à vos démarches administratives',
          onTap: () => context.push('/procedures'),
        ),
        OrbitalItem(
          icon: Icons.chat_bubble_rounded,
          label: 'Messagerie',
          color: const Color(0xFF00BCD4),
          description: 'Communiquez avec la communauté',
          onTap: () => context.push('/chat'),
        ),
        OrbitalItem(
          icon: Icons.forum_rounded,
          label: 'Communauté',
          color: const Color(0xFFE91E63),
          description: 'Participez aux discussions de la diaspora',
          onTap: () => context.push('/community'),
        ),
        OrbitalItem(
          icon: Icons.groups_rounded,
          label: 'Comités',
          color: const Color(0xFF4CAF50),
          description: 'Rejoignez et gérez vos comités',
          onTap: () => context.push('/committee'),
        ),
        OrbitalItem(
          icon: Icons.person_rounded,
          label: 'Profil',
          color: Colors.orange,
          description: 'Gérez votre profil et paramètres',
          onTap: () => context.push('/profile'),
        ),
      ],
      fabColor: AppColors.primary,
      onOpen: () => debugPrint('Orbital opened'),
      onClose: () => debugPrint('Orbital closed'),
      onLogout: () async {
        await ref.read(authNotifierProvider.notifier).logout();
        if (context.mounted) context.go('/onboarding');
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextMain(context),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _MenuItem(this.icon, this.label, this.route, this.color);
}

class _MenuGridSection extends StatelessWidget {
  const _MenuGridSection();

  static const _items = [
    _MenuItem(
      Icons.wallet_rounded,
      'Portefeuille',
      '/wallet',
      AppColors.primary,
    ),
    _MenuItem(
      Icons.description_rounded,
      'Documents',
      '/documents',
      AppColors.secondary,
    ),
    _MenuItem(
      Icons.storefront_rounded,
      'Marketplace',
      '/marketplace',
      AppColors.accent,
    ),
    _MenuItem(
      Icons.fact_check_rounded,
      'Démarches',
      '/procedures',
      Color(0xFF8B5CF6),
    ),
    _MenuItem(
      Icons.chat_bubble_rounded,
      'Messagerie',
      '/chat',
      AppColors.accent,
    ),
    _MenuItem(Icons.settings_rounded, 'Réglages', '/settings', Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return NeumorphicContainer(
              key: ValueKey(item.route),
              borderRadius: 24,
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.color, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMain(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: (200 + index * 50).ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

class _CommitteeListSection extends ConsumerWidget {
  const _CommitteeListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Type conservé en AsyncValue non générique, comme dans l'original :
    // le type exact de l'entité "committee" ne m'a pas été fourni.
    final AsyncValue committeesAsync = ref.watch(committeesProvider);

    return committeesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur lors du chargement des comités'),
      data: (committees) {
        if (committees.isEmpty) {
          return const Text('Rejoignez un comité pour voir vos activités.');
        }
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: committees.length,
            itemBuilder: (context, index) {
              final c = committees[index];
              return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        NeumorphicContainer(
                          width: 64,
                          height: 64,
                          borderRadius: 32,
                          child: InkWell(
                            onTap: () => context.push('/committee'),
                            borderRadius: BorderRadius.circular(32),
                            child: Center(
                              child: Text(
                                initialOf(c.name),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMain(context),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (400 + index * 100).ms)
                  .slideX(begin: 0.2);
            },
          ),
        );
      },
    );
  }
}

class _ProceduresHighlightSection extends ConsumerWidget {
  const _ProceduresHighlightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proceduresState = ref.watch(proceduresProvider);

    if (proceduresState.isLoading && proceduresState.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (proceduresState.items.isEmpty) return const SizedBox();

    final p = proceduresState.items.first;
    final isCompleted = proceduresState.completedProcedureIds.contains(p.id);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCompleted
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child:
                  isCompleted
                      ? const Icon(
                        Icons.check_rounded,
                        size: 24,
                        color: AppColors.accent,
                      )
                      : const Icon(
                        Icons.article_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.getTextMain(context),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.accent.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  p.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push('/procedures'),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }
}

class _CommunityFeedSection extends ConsumerWidget {
  const _CommunityFeedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Type conservé en AsyncValue non générique, comme dans l'original :
    // le type exact de l'entité "post" ne m'a pas été fourni.
    final AsyncValue postsAsync = ref.watch(communityNotifierProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur feed'),
      data: (posts) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length > 3 ? 3 : posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(initialOf(post.authorName)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                post.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.getTextSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (600 + index * 100).ms)
                  .slideX(begin: 0.05),
            );
          },
        );
      },
    );
  }
}


