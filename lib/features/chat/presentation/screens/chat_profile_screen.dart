import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';

class ChatProfileScreen extends StatelessWidget {
  const ChatProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E1621) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor:
                isDark ? const Color(0xFF0E1621) : const Color(0xFFE8F5E9),
            leading: const SizedBox.shrink(),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildExpandedHeader(context, isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildActionButtons(context, isDark),
          ),
          SliverToBoxAdapter(
            child: _buildDetailsSection(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? const Color(0xFF1A2940) : const Color(0xFFE8F5E9),
            isDark ? const Color(0xFF0E1621) : Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                'K',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Koffi Togolais',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMain(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'En ligne',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionCircle(
              icon: Icons.call_rounded,
              label: 'Appel',
              color: AppColors.primary,
              isDark: isDark),
          _ActionCircle(
              icon: Icons.videocam_rounded,
              label: 'Vidéo',
              color: AppColors.primary,
              isDark: isDark),
          _ActionCircle(
              icon: Icons.notifications_none_rounded,
              label: 'Mute',
              color: AppColors.getTextSecondary(context),
              isDark: isDark),
          _ActionCircle(
              icon: Icons.search_rounded,
              label: 'Recherche',
              color: AppColors.getTextSecondary(context),
              isDark: isDark),
          _ActionCircle(
              icon: Icons.more_vert_rounded,
              label: 'Plus',
              color: AppColors.getTextSecondary(context),
              isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            label: 'Chaîne',
            value: '2.7K abonnés',
            icon: Icons.campaign_rounded,
          ),
          _buildDetailRow(
            context,
            label: 'Mobile',
            value: '+228 90 00 00 00',
            icon: Icons.phone_rounded,
            valueColor: AppColors.primary,
          ),
          _buildDetailRow(
            context,
            label: 'Nom d\'utilisateur',
            value: '@ktogolais',
            icon: Icons.alternate_email_rounded,
            valueColor: AppColors.primary,
          ),
          _buildDetailRow(
            context,
            label: 'Date de naissance',
            value: '15 Mars 1995 (31 an)',
            icon: Icons.cake_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.getTextSecondary(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? AppColors.getTextMain(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : color.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.getTextSecondary(context),
          ),
        ),
      ],
    );
  }
}
