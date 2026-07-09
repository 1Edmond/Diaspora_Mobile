import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';

class ChatProfileScreen extends StatelessWidget {
  const ChatProfileScreen({super.key});

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
                  const SizedBox(height: 40),
                  _buildAvatar(context),
                  const SizedBox(height: 16),
                  Text('Koffi Togolais', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
                  const SizedBox(height: 4),
                  Text('En ligne', style: TextStyle(fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('+228 90 00 00 00', style: TextStyle(fontSize: 14, color: AppColors.getTextSecondary(context))),
                  const SizedBox(height: 28),
                  _MenuTile(icon: Icons.notifications_none_rounded, label: 'Notifications'),
                  _MenuTile(icon: Icons.message_outlined, label: 'Messages archivés'),
                  _MenuTile(icon: Icons.folder_outlined, label: 'Fichiers et médias'),
                  _MenuTile(icon: Icons.palette_outlined, label: 'Apparence'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
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
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 24),
          title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.getTextMain(context))),
          trailing: Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondary(context)),
          onTap: () {},
        ),
        Divider(height: 1, indent: 56, color: AppColors.getTextSecondary(context).withValues(alpha: 0.12)),
      ],
    );
  }
}
