import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 32),
                  _buildProfileHeader(context),
                  const SizedBox(height: 40),
                  _buildMenuSection(context, 'Informations Personnelles', [
                    _ProfileMenuItem(
                      Icons.person_outline_rounded,
                      'Détails du compte',
                    ),
                    _ProfileMenuItem(Icons.email_outlined, 'Email et Contact'),
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuSection(context, 'Sécurité et Accès', [
                    _ProfileMenuItem(
                      Icons.lock_outline_rounded,
                      'Changer le mot de passe',
                    ),
                    _ProfileMenuItem(Icons.fingerprint_rounded, 'Biométrie'),
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuSection(context, 'Préférences', [
                    _ProfileMenuItem(
                      Icons.notifications_none_rounded,
                      'Notifications',
                    ),
                    _ProfileMenuItem(Icons.language_rounded, 'Langue'),
                  ]),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -150,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.getTextMain(context),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        Text(
          'Mon Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const SizedBox(width: 48), // Balance
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: NeumorphicContainer(
            width: 120,
            height: 120,
            borderRadius: 60,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Koffi Togolais',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const Text(
          'Membre Premium — Togo',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildMenuSection(BuildContext context, String title, List<_ProfileMenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.map((item) => _buildTile(context, item)).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildTile(BuildContext context, _ProfileMenuItem item) {
    return ListTile(
      leading: Icon(item.icon, color: AppColors.primary, size: 22),
      title: Text(
        item.label,
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
      onTap: () {},
    );
  }

  Widget _buildLogoutButton() {
    return NeumorphicContainer(
      width: double.infinity,
      height: 56,
      color: Colors.red.withValues(alpha: 0.05),
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Se déconnecter',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String label;
  _ProfileMenuItem(this.icon, this.label);
}
