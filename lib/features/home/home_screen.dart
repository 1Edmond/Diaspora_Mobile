import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../shared/widgets/containers/glass_container.dart';
import '../../shared/widgets/containers/neumorphic_container.dart';
import '../community/presentation/controllers/community_notifier.dart';
import '../committee/presentation/controllers/committee_notifiers.dart';
import '../procedures/presentation/controllers/procedures_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityNotifierProvider);
    final committeesAsync = ref.watch(committeesProvider);
    final proceduresAsync = ref.watch(proceduresProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If we want to show a confirm dialog or just do nothing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appuyez encore pour quitter'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(communityNotifierProvider.notifier)
                      .loadPosts(refresh: true);
                  await ref.read(proceduresProvider.notifier).fetch();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Services rapides'),
                            const SizedBox(height: 16),
                            _buildMenuGrid(context),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Actualités Communauté'),
                            const SizedBox(height: 16),
                            _buildCommunityFeed(postsAsync, context),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Vos Démarches'),
                            const SizedBox(height: 16),
                            _buildProceduresHighlight(proceduresAsync, context),
                            const SizedBox(height: 32),
                            _buildSectionHeader('Comités Actifs'),
                            const SizedBox(height: 16),
                            _buildCommitteeList(committeesAsync, context),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNav(context),
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

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Hero(
            tag: 'profile_avatar',
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Koffi Togolais',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          NeumorphicContainer(
            width: 48,
            height: 48,
            borderRadius: 24,
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textMain,
                size: 24,
              ),
              onPressed: () => context.push('/notifications'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = [
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
        Icons.assignment_rounded,
        'Services',
        '/services',
        AppColors.accent,
      ),
      _MenuItem(
        Icons.chat_bubble_rounded,
        'Messagerie',
        '/chat',
        AppColors.accent,
      ),
      _MenuItem(
        Icons.settings_rounded,
        'Réglages',
        '/settings',
        Colors.blueGrey,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return NeumorphicContainer(
              borderRadius: 24,
              child: InkWell(
                onTap: () => context.push(items[index].route),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: items[index].color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          items[index].icon,
                          color: items[index].color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                          fontSize: 13,
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

  Widget _buildCommitteeList(AsyncValue committeesAsync, BuildContext context) {
    return committeesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Erreur lors du chargement des comités'),
      data: (committees) {
        if (committees.isEmpty)
          return const Text('Rejoignez un comité pour voir vos activités.');
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
                                c.name[0].toUpperCase(),
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
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMain,
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

  Widget _buildProceduresHighlight(
    AsyncValue proceduresAsync,
    BuildContext context,
  ) {
    return proceduresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
      data: (items) {
        if (items.isEmpty) return const SizedBox();
        final p = items.first;
        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: p.userProgress / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                  Text(
                    '${p.userProgress}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      p.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.push('/procedures'),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildCommunityFeed(AsyncValue postsAsync, BuildContext context) {
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
                          child: Text(post.authorName[0]),
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
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
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

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: 30,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_rounded),
              label: 'Communauté',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
              label: 'Comités',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          onTap: (index) {
            final routes = ['/home', '/community', '/committee', '/profile'];
            if (index > 0) context.push(routes[index]);
          },
        ),
      ),
    ).animate().slideY(begin: 1.0, curve: Curves.easeOutBack, duration: 800.ms);
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  _MenuItem(this.icon, this.label, this.route, this.color);
}
