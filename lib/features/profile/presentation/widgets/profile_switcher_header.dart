import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_providers.dart';
import '../controllers/profile_switcher_provider.dart';
import 'profile_selection_sheet.dart';
import 'profile_confirmation_toast.dart';

class ProfileSwitcherHeader extends ConsumerStatefulWidget {
  final bool isCompact;
  final bool showNotificationBell;

  const ProfileSwitcherHeader({
    super.key,
    this.isCompact = false,
    this.showNotificationBell = true,
  });

  @override
  ConsumerState<ProfileSwitcherHeader> createState() =>
      _ProfileSwitcherHeaderState();
}

class _ProfileSwitcherHeaderState extends ConsumerState<ProfileSwitcherHeader> {
  double _dragOffset = 0;
  static const double _dragThreshold = 80;

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _dragThreshold) {
      final notifier = ref.read(profileSwitcherProvider.notifier);
      if (_dragOffset > 0) {
        notifier.switchToPrevious();
      } else {
        notifier.switchToNext();
      }
      _showConfirmationToast();
    }
    setState(() => _dragOffset = 0);
  }

  void _showConfirmationToast() {
    final profile = ref.read(activeProfileProvider);
    if (profile != null) {
      ProfileConfirmationToast.show(context, profile.fullName);
    }
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() => _dragOffset += details.delta.dx);
      },
      onHorizontalDragEnd: _onDragEnd,
      onTap: _showProfileSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.isCompact ? 8 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(profile),
            const SizedBox(width: 12),
            _buildInfo(profile),
            const Spacer(),
            if (widget.showNotificationBell) ...[
              _buildNotificationIcon(),
              const SizedBox(width: 8),
            ],
            _buildChevron(),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildAvatar(Profile? profile) {
    final color = profile?.effectiveColor ?? AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isCompact ? 40 : 56,
      height: widget.isCompact ? 40 : 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: Text(
          profile?.firstName.substring(0, 1) ?? '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isCompact ? 16 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(Profile? profile) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                profile?.fullName ?? 'Aucun profil',
                style: TextStyle(
                  fontSize: widget.isCompact ? 14 : 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextMain(context),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: widget.isCompact ? 14 : 20,
                color: AppColors.getTextSecondary(context),
              ),
            ],
          ),
          if (!widget.isCompact && profile != null) ...[
            const SizedBox(height: 2),
            Text(
              '${profile.isInternal ? "Interne" : "Externe"}${profile.universityOrCompany != null ? " – ${profile.universityOrCompany}" : ""}',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.notifications_outlined,
        size: 20,
        color: AppColors.getTextSecondary(context),
      ),
    );
  }

  Widget _buildChevron() {
    return Icon(
      Icons.chevron_right,
      color: AppColors.getTextSecondary(context),
    );
  }
}
