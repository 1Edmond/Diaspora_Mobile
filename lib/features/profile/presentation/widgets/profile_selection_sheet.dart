import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_providers.dart';
import '../controllers/profile_switcher_provider.dart';
import 'profile_confirmation_toast.dart';
import 'profile_creation_flow.dart';

class ProfileSelectionSheet extends ConsumerStatefulWidget {
  const ProfileSelectionSheet({super.key});

  @override
  ConsumerState<ProfileSelectionSheet> createState() =>
      _ProfileSelectionSheetState();
}

class _ProfileSelectionSheetState extends ConsumerState<ProfileSelectionSheet> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final activeId = ref.read(activeProfileIdProvider);
    final profiles = ref.read(profileListProvider).valueOrNull ?? [];
    _currentPage = profiles.indexWhere((p) => p.id == activeId);
    if (_currentPage < 0) _currentPage = 0;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.75,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onProfileSelected(Profile profile) {
    ref.read(profileSwitcherProvider.notifier).switchToProfile(profile.id);
    ProfileConfirmationToast.show(context, profile.fullName);
    Navigator.of(context).pop();
  }

  void _showCreationFlow() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileCreationFlow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileListProvider).valueOrNull ?? [];
    final activeId = ref.watch(activeProfileIdProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildPageView(profiles, activeId),
                    const SizedBox(height: 16),
                    _buildDotsIndicator(profiles.length),
                    const SizedBox(height: 16),
                    _buildProfileList(profiles, activeId),
                    const SizedBox(height: 16),
                    _buildAddProfileButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes profils',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionnez le profil à utiliser',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(List<Profile> profiles, String? activeId) {
    if (profiles.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Aucun profil')),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: profiles.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          final profile = profiles[index];
          final isActive = profile.id == activeId;
          return GestureDetector(
            onTap: () => _onProfileSelected(profile),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    profile.effectiveColor,
                    profile.effectiveColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: profile.effectiveColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (isActive)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: profile.effectiveColor,
                          size: 16,
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            profile.firstName.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.displaySubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        if (profile.statusLabel != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  profile.isPending
                                      ? Icons.hourglass_empty_rounded
                                      : Icons.error_outline_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  profile.statusLabel!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (isActive) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Actif',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildProfileList(List<Profile> profiles, String? activeId) {
    return Column(
      children: profiles.map((profile) {
        final isActive = profile.id == activeId;
        return GestureDetector(
          onTap: () => _onProfileSelected(profile),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? profile.effectiveColor.withValues(alpha: 0.05)
                  : AppColors.getTextSecondary(context).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? profile.effectiveColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: profile.effectiveColor.withValues(alpha: 0.1),
                  child: Text(
                    profile.firstName.substring(0, 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: profile.effectiveColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            profile.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? profile.effectiveColor
                                  : AppColors.getTextMain(context),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: profile.effectiveColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Actif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (profile.statusLabel != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: profile.statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                profile.statusLabel!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: profile.statusColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.displaySubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(Icons.check_circle, color: profile.effectiveColor)
                else
                  Icon(Icons.radio_button_unchecked,
                      color: AppColors.getTextSecondary(context)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddProfileButton() {
    return GestureDetector(
      onTap: _showCreationFlow,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Ajouter un profil',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
