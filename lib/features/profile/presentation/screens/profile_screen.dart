import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildAvatar(context),
                  const SizedBox(height: 16),
                  Text('Koffi Togolais', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
                  const SizedBox(height: 4),
                  Text('Membre Premium — Togo', style: TextStyle(fontSize: 15, color: AppColors.accent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('+228 90 00 00 00', style: TextStyle(fontSize: 14, color: AppColors.getTextSecondary(context))),
                  const SizedBox(height: 24),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(icon: Icons.person_outline_rounded, label: 'Détails du compte'),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(icon: Icons.email_outlined, label: 'Email et Contact'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(icon: Icons.lock_outline_rounded, label: 'Changer le mot de passe'),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(icon: Icons.fingerprint_rounded, label: 'Biométrie'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    context,
                    child: Column(
                      children: [
                        _ProfileTile(icon: Icons.notifications_none_rounded, label: 'Notifications'),
                        const Divider(height: 1, indent: 52),
                        _ProfileTile(icon: Icons.language_rounded, label: 'Langue'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
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
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.getTextMain(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        Text('Mon Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
          ),
          child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
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
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
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
          onPressed: () {},
          child: const Text('Se déconnecter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProfileTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.getTextMain(context))),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.getTextSecondary(context)),
      onTap: () {},
    );
  }
}
