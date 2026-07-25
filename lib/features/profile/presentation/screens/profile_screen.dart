import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../presentation/controllers/profile_providers.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/constants/enums.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);
    final user = userAsync.valueOrNull;
    final activeProfile = ref.watch(activeProfileProvider);
    final profilesAsync = ref.watch(profileListProvider);
    final profiles = profilesAsync.valueOrNull ?? [];

    final name =
        activeProfile?.fullName ??
        user?.email?.split('@').first ??
        'Utilisateur';
    final email = user?.email ?? '';
    final phone = user?.togolesePhoneNumber ?? '';
    final profileType = activeProfile?.profileType ?? '—';
    final profileStatus = activeProfile?.status;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.getBackground(context),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(context),
                  const SizedBox(height: 4),
                  _buildAvatar(context, name),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextMain(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profil $profileType',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone.isNotEmpty ? phone : email,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                  if (profileStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _buildStatusBadge(context, profileStatus),
                    ),
                  const SizedBox(height: 24),
                  _buildProfilesCard(context, profiles, activeProfile),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Détails du compte',
                          onTap: () => context.push('/settings'),
                        ),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(
                          icon: Icons.email_outlined,
                          label: 'Email et Contact',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Changer le mot de passe',
                          onTap: () => context.push('/settings'),
                        ),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(
                          icon: Icons.fingerprint_rounded,
                          label: 'Biométrie',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifications',
                          onTap: () => context.go('/notifications'),
                        ),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(
                          icon: Icons.language_rounded,
                          label: 'Langue',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ProfileStatus status) {
    final (label, color) = switch (status) {
      ProfileStatus.VALIDATED => ('Validé', AppColors.accent),
      ProfileStatus.REJECTED => ('Rejeté', Colors.red),
      ProfileStatus.PENDING => ('En attente', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProfilesCard(
    BuildContext context,
    List<Profile> profiles,
    Profile? activeProfile,
  ) {
    return _buildGlassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Mes Profils',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMain(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '${profiles.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          ...profiles.take(3).map((p) {
            final isActive = p.id == activeProfile?.id;
            return ListTile(
              leading: Icon(
                p.isInternal ? Icons.person_rounded : Icons.public_rounded,
                color:
                    isActive
                        ? AppColors.primary
                        : AppColors.getTextSecondary(context),
                size: 22,
              ),
              title: Text(
                p.fullName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.getTextMain(context),
                ),
              ),
              subtitle: Text(
                '${p.profileType} — ${p.profileTypeId}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              trailing:
                  isActive
                      ? Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                      : Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: AppColors.getTextSecondary(context),
                        size: 20,
                      ),
              onTap: isActive ? null : () => context.push('/profiles'),
            );
          }),
          if (profiles.length > 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () => context.push('/profiles'),
                child: Text(
                  'Voir tous les profils (${profiles.length})',
                  style: TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ),
          if (profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun profil chargé',
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.getTextMain(context),
          ),
          onPressed: () {
            try {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            } catch (_) {
              context.go('/home');
            }
          },
        ),
        const Spacer(),
        Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, String name) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.red.withValues(alpha: 0.06),
          border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
        ),
        child: TextButton(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).logout();
            if (context.mounted) context.go('/auth/login');
          },
          child: const Text(
            'Se déconnecter',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _ProfileTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.getTextMain(context),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.getTextSecondary(context),
      ),
      onTap: onTap,
    );
  }
}
