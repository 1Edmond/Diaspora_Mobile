import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/config/feature_flags.dart';
import '../../core/di/injection.dart';
import '../../core/network/token_service.dart';
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
import '../auth/presentation/controllers/auth_restore_provider.dart';
import '../settings/presentation/controllers/settings_notifier.dart';
import '../settings/domain/entities/settings_entity.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndProfiles();
    });
  }

  Future<void> _checkAuthAndProfiles() async {
    if (!mounted) return;

    // 1. Check token validity in real mode
    if (!AppConfig.useMockData) {
      final tokenService = getIt.isRegistered<TokenService>()
          ? getIt<TokenService>()
          : TokenService();
      final authRestored = ref.read(authRestoredProvider);
      final isRefreshTokenExpired = tokenService.isRefreshTokenExpired;
      final hasAnyToken = tokenService.hasAccessToken || tokenService.hasRefreshToken;

      if (authRestored == false || !hasAnyToken || (tokenService.hasRefreshToken && isRefreshTokenExpired)) {
        if (mounted) {
          context.go('/auth/login');
        }
        return;
      }
    }

    // 2. Check profile availability
    var activeProfile = ref.read(activeProfileProvider);
    var profiles = ref.read(profileListProvider).valueOrNull ?? [];

    if (activeProfile == null && profiles.isEmpty) {
      await ref.read(authNotifierProvider.notifier).fetchProfiles();
      if (!mounted) return;
      activeProfile = ref.read(activeProfileProvider);
      profiles = ref.read(profileListProvider).valueOrNull ?? [];

      if (activeProfile == null && profiles.isEmpty) {
        if (mounted) {
          context.go('/auth/login');
        }
        return;
      }
    }
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
    ref.listen(authRestoredProvider, (prev, next) {
      if (next == false && mounted) {
        context.go('/auth/login');
      }
    });

    ref.listen(profileListProvider, (prev, next) {
      if (prev?.isLoading == true &&
          next.hasValue &&
          next.value!.isEmpty &&
          ref.read(activeProfileProvider) == null &&
          mounted) {
        context.go('/auth/login');
      }
    });

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
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: _HomeSections(),
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
    final items = [
      if (FeatureFlags.enableWallet)
        OrbitalItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Portefeuille',
          color: AppColors.primary,
          description: 'Gérez votre portefeuille et vos transactions',
          onTap: () => context.push('/wallet'),
        ),
      if (FeatureFlags.enableDocuments)
        OrbitalItem(
          icon: Icons.description_rounded,
          label: 'Documents',
          color: AppColors.secondary,
          description: 'Ajoutez et consultez vos documents administratifs',
          onTap: () => context.push('/documents'),
        ),
      if (FeatureFlags.enableMarketplace)
        OrbitalItem(
          icon: Icons.storefront_rounded,
          label: 'Marketplace',
          color: AppColors.accent,
          description: 'Découvrez services et annonces de la diaspora',
          onTap: () => context.push('/marketplace'),
        ),
      if (FeatureFlags.enableProcedures)
        OrbitalItem(
          icon: Icons.fact_check_rounded,
          label: 'Démarches',
          color: const Color(0xFF8B5CF6),
          description: 'Accédez à vos démarches administratives',
          onTap: () => context.push('/procedures'),
        ),
      if (FeatureFlags.enableChat)
        OrbitalItem(
          icon: Icons.chat_bubble_rounded,
          label: 'Messagerie',
          color: const Color(0xFF00BCD4),
          description: 'Communiquez avec la communauté',
          onTap: () => context.push('/chat'),
        ),
      if (FeatureFlags.enableCommunity)
        OrbitalItem(
          icon: Icons.forum_rounded,
          label: 'Communauté',
          color: const Color(0xFFE91E63),
          description: 'Participez aux discussions de la diaspora',
          onTap: () => context.push('/community'),
        ),
      if (FeatureFlags.enableCommittee)
        OrbitalItem(
          icon: Icons.groups_rounded,
          label: 'Comités',
          color: const Color(0xFF4CAF50),
          description: 'Rejoignez et gérez vos comités',
          onTap: () => context.push('/committee'),
        ),
      if (FeatureFlags.enableProfile)
        OrbitalItem(
          icon: Icons.person_rounded,
          label: 'Profil',
          color: Colors.orange,
          description: 'Gérez votre profil et paramètres',
          onTap: () => context.push('/profile'),
        ),
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return OrbitalFab(
      items: items,
      fabColor: AppColors.primary,
      onOpen: () => debugPrint('Orbital opened'),
      onClose: () => debugPrint('Orbital closed'),
      onLogout: () async {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.logout();
        if (mounted) context.go('/onboarding');
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Tout voir',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }
}

/// Assembles the home page's content sections in order, each individually
/// toggleable from Réglages > Accueil. Sections animate in/out with
/// AnimatedSwitcher when their visibility is toggled live, rather than
/// just popping — and each section's own internal content still does its
/// staggered entrance animation the first time it appears.
class _HomeSections extends ConsumerWidget {
  const _HomeSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider).valueOrNull ??
        const SettingsEntity();

    final hasQuickAccess = FeatureFlags.enableWallet ||
        FeatureFlags.enableDocuments ||
        FeatureFlags.enableMarketplace ||
        FeatureFlags.enableProcedures ||
        FeatureFlags.enableChat ||
        FeatureFlags.enableServices ||
        FeatureFlags.enableCommunity ||
        FeatureFlags.enableFreelance ||
        FeatureFlags.enableCommittee ||
        FeatureFlags.enableSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedSection(
          visible: settings.homeShowQuickAccess && hasQuickAccess,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'Services rapides'),
              const SizedBox(height: 16),
              _MenuGridSection(horizontal: settings.homeQuickAccessHorizontal),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const _FeatureHighlightsSection(),
        _AnimatedSection(
          visible: settings.homeShowProceduresStats && FeatureFlags.enableProcedures,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Vos démarches',
                onSeeAll: () => context.push('/procedures'),
              ),
              const SizedBox(height: 16),
              const _ProceduresStatsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        _AnimatedSection(
          visible: settings.homeShowCommunityFeed && FeatureFlags.enableCommunity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Actualités communauté',
                onSeeAll: () => context.push('/community'),
              ),
              const SizedBox(height: 16),
              const _CommunityFeedSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        _AnimatedSection(
          visible: settings.homeShowCommitteeList && FeatureFlags.enableCommittee,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Comités actifs'),
              SizedBox(height: 16),
              _CommitteeListSection(),
              SizedBox(height: 32),
            ],
          ),
        ),
        const SizedBox(height: 68),
      ],
    );
  }
}

class _FeatureHighlightsSection extends ConsumerWidget {
  const _FeatureHighlightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeProfile != null && activeProfile.verificationLevel < 2) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vérification KYC • ${activeProfile.countryDisplay}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.getTextMain(context),
                            ),
                          ),
                          Text(
                            'Niveau actuel : ${activeProfile.verificationLevelLabel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Fournissez vos justificatifs pour débloquer tous les services et obtenir votre badge vérifié.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => context.push('/profile/kyc'),
                    child: const Text('Vérifier mon identité (KYC)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (FeatureFlags.enableMarketplace) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Colis & Trajets P2P',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.getTextMain(context),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Séquestre sécurisé',
                        style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Expédiez vos colis ou rentabilisez vos trajets entre pays de la diaspora en toute confiance.',
                  style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/marketplace'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Rechercher un trajet', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push('/marketplace/travel/create'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Publier un voyage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _AnimatedSection({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: visible
            ? child
            : const SizedBox(width: double.infinity, key: ValueKey('hidden')),
      ),
    );
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
  final bool horizontal;
  const _MenuGridSection({this.horizontal = true});

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
    _MenuItem(
      Icons.handyman_rounded,
      'Services',
      '/marketplace',
      Color(0xFF0D9488),
    ),
    _MenuItem(
      Icons.people_rounded,
      'Communauté',
      '/community',
      Color(0xFFF59E0B),
    ),
    _MenuItem(
      Icons.work_rounded,
      'Freelance',
      '/freelance',
      Color(0xFFEC4899),
    ),
    _MenuItem(Icons.settings_rounded, 'Réglages', '/settings', Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    final activeItems = _items
        .where((item) => FeatureFlags.isRouteEnabled(item.route))
        .toList();

    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    if (horizontal) {
      if (activeItems.length <= 4) {
        return SizedBox(
          height: 92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: activeItems.asMap().entries.map((entry) {
              return Expanded(
                child: Center(
                  child: _QuickAccessBubble(
                    item: entry.value,
                    index: entry.key,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }
      return SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: activeItems.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) => _QuickAccessBubble(
            item: activeItems[index],
            index: index,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = activeItems.length;
        int crossAxisCount;
        double childAspectRatio;

        if (count == 1) {
          crossAxisCount = 1;
          childAspectRatio = constraints.maxWidth > 400 ? 3.5 : 2.6;
        } else if (count == 2) {
          crossAxisCount = 2;
          childAspectRatio = 1.6;
        } else if (count == 3) {
          crossAxisCount = constraints.maxWidth >= 340 ? 3 : 1;
          childAspectRatio = constraints.maxWidth >= 340 ? 1.05 : 2.8;
        } else if (count == 4) {
          crossAxisCount = 2;
          childAspectRatio = 1.45;
        } else {
          if (constraints.maxWidth >= 600) {
            crossAxisCount = count >= 4 ? 4 : count;
            childAspectRatio = 1.3;
          } else if (constraints.maxWidth >= 450) {
            crossAxisCount = 3;
            childAspectRatio = 1.2;
          } else {
            crossAxisCount = 2;
            childAspectRatio = 1.4;
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: activeItems.length,
          itemBuilder: (context, index) {
            final item = activeItems[index];
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
                        textAlign: TextAlign.center,
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
      },
    );
  }
}

/// The horizontal "bubble" layout: a big circular icon with a subtle
/// gradient ring, a bouncy staggered entrance, and a press-down scale
/// animation on tap — meant to feel a bit more alive than the grid.
class _QuickAccessBubble extends StatefulWidget {
  final _MenuItem item;
  final int index;
  const _QuickAccessBubble({required this.item, required this.index});

  @override
  State<_QuickAccessBubble> createState() => _QuickAccessBubbleState();
}

class _QuickAccessBubbleState extends State<_QuickAccessBubble> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => context.push(item.route),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withValues(alpha: 0.18),
                      item.color.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(color: item.color.withValues(alpha: 0.25)),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextMain(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (150 + widget.index * 70).ms, duration: 350.ms)
        .slideY(begin: 0.4, curve: Curves.easeOutBack)
        .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack);
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

/// Replaces the old "show the first procedure" section: a compact stats
/// row (not a list of every procedure) — total, in progress, completed,
/// not started — each tappable to jump to the filtered procedures list.
class _ProceduresStatsSection extends ConsumerWidget {
  const _ProceduresStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proceduresProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.items.isEmpty) return const SizedBox();

    final total = state.items.length;
    final completed = state.completedProcedureIds.length;
    final inProgress = state.startedProcedureIds
        .difference(state.completedProcedureIds)
        .length;
    final notStarted = (total - state.startedProcedureIds.length).clamp(0, total);

    final stats = [
      (
        'Total',
        total,
        Icons.folder_copy_rounded,
        AppColors.primary,
      ),
      (
        'En cours',
        inProgress,
        Icons.hourglass_top_rounded,
        const Color(0xFFF59E0B),
      ),
      (
        'Terminées',
        completed,
        Icons.check_circle_rounded,
        AppColors.accent,
      ),
      (
        'À faire',
        notStarted,
        Icons.radio_button_unchecked_rounded,
        AppColors.getTextSecondary(context),
      ),
    ];

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++)
            Expanded(
              child: _StatPill(
                label: stats[i].$1,
                value: stats[i].$2,
                icon: stats[i].$3,
                color: stats[i].$4,
                delay: i * 100,
                onTap: () => context.push('/procedures'),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: 700.ms,
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, _) => Text(
              '$animatedValue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.getTextMain(context),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (500 + delay).ms).scale(begin: const Offset(0.7, 0.7));
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


