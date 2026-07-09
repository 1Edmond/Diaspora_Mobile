import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/community_notifier.dart';
import '../widgets/post_card.dart';

class CommunityHomeScreen extends ConsumerStatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  ConsumerState<CommunityHomeScreen> createState() =>
      _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends ConsumerState<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: NestedScrollView(
              headerSliverBuilder:
                  (context, innerBoxIsScrolled) => [
                    _buildSliverAppBar(),
                    _buildHeaderStats(),
                    _buildSliverTabs(),
                  ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(postsAsync),
                  _buildEventsTab(),
                  _buildScholarshipsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicContainer(
        width: 60,
        height: 60,
        borderRadius: 30,
        color: AppColors.primary,
        child: IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          onPressed: () => context.go('/community/create'),
        ),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.getTextMain(context), size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Communauté',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextMain(context),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.getTextMain(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Points',
                '1,250',
                Icons.stars_rounded,
                AppColors.accent,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                'Posts',
                '24',
                Icons.article_rounded,
                AppColors.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                'Amis',
                '158',
                Icons.people_rounded,
                AppColors.secondary,
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabDelegate(
        TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.getTextSecondary(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Actualités'),
            Tab(text: 'Événements'),
            Tab(text: 'Bourses'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab(AsyncValue postsAsync) {
    return RefreshIndicator(
      onRefresh:
          () async => ref
              .read(communityNotifierProvider.notifier)
              .loadPosts(refresh: true),
      child: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
        data:
            (posts) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: PostCard(
                          post: posts[index],
                          onTap:
                              () => context.go(
                                '/community/post/${posts[index].id}',
                              ),
                          onLike: () {},
                          onComment: () {},
                          onShare: () {},
                        )
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .slideX(begin: 0.1),
                  ),
            ),
      ),
    );
  }

  Widget _buildEventsTab() {
    final events = [
      {
        'title': 'Forum de la Diaspora',
        'date': '15 Mars 2026',
        'location': 'Paris, France',
        'image':
            'https://images.unsplash.com/photo-1540575861501-7ad058bf3efb?w=500',
        'category': 'Conférence',
      },
      {
        'title': 'Atelier Entrepreneuriat',
        'date': '22 Mars 2026',
        'location': 'Dakar, Sénégal (Hybride)',
        'image':
            'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=500',
        'category': 'Workshop',
      },
      {
        'title': 'Gala de Bienfaisance',
        'date': '10 Avril 2026',
        'location': 'Abidjan, Côte d\'Ivoire',
        'image':
            'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=500',
        'category': 'Social',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeumorphicContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    event['image']!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              event['category']!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            event['date']!,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event['title']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextMain(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.getTextSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event['location']!,
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildScholarshipsTab() {
    final scholarships = [
      {
        'title': 'Bourse d\'Excellence Diaspora',
        'amount': '5,000 €',
        'deadline': '30 Avril 2026',
        'provider': 'Fondation Diaspora Plus',
      },
      {
        'title': 'Aide à la Reconversion',
        'amount': '2,500 €',
        'deadline': 'Validité Permanente',
        'provider': 'Ministère de l\'Économie',
      },
      {
        'title': 'Soutien Étudiants Master',
        'amount': '1,200 € / an',
        'deadline': '15 Août 2026',
        'provider': 'Association des Cadres',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scholarships.length,
      itemBuilder: (context, index) {
        final s = scholarships[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.getTextMain(context),
                        ),
                      ),
                      Text(
                        s['provider']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s['amount']!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Jusqu\'au ${s['deadline']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
      },
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.getBackground(context), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}
