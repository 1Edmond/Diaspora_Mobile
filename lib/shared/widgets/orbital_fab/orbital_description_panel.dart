import 'package:flutter/material.dart';
import 'orbital_data.dart';

class OrbitalDescriptionPanel extends StatelessWidget {
  final OrbitalItem item;
  final Animation<double> animation;
  final VoidCallback? onDiscover;
  final VoidCallback? onLogout;

  const OrbitalDescriptionPanel({
    super.key,
    required this.item,
    required this.animation,
    this.onDiscover,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(-30 * (1 - animation.value), 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconBadge(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildHeading(),
            const SizedBox(height: 14),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildDiscoverButton(),
            if (onLogout != null) ...[
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildLogoutButton(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.icon,
        color: item.color,
        size: 24,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      item.label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: item.color,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildHeading() {
    return Text(
      _getHeadingForItem(item.label),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.grey[900],
        height: 1.2,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      item.description ?? '',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[500],
        height: 1.5,
      ),
    );
  }

  Widget _buildDiscoverButton() {
    return GestureDetector(
      onTap: onDiscover,
      child: FittedBox(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: item.color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Découvrir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: item.color,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: onLogout,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFCD0021).withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFCD0021).withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFCD0021),
          size: 20,
        ),
      ),
    );
  }

  String _getHeadingForItem(String label) {
    switch (label) {
      case 'Documents':
        return 'Gérez tous vos\ndocuments en un\nseul endroit';
      case 'Portefeuille':
        return 'Gérez votre\nportefeuille en\ntoute sécurité';
      case 'Démarches':
        return 'Suivez vos\ndémarches\nfacilement';
      case 'Services':
        return 'Découvrez nos\nservices pour\nla diaspora';
      case 'Messagerie':
        return 'Communiquez\navec la\ncommunauté';
      case 'Profil':
        return 'Gérez votre\nprofil et vos\nparamètres';
      default:
        return 'Découvrez\n$label';
    }
  }
}
