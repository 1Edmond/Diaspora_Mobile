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
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const ProfileSwitcherHeader({
    super.key,
    this.isCompact = false,
    this.showNotificationBell = true,
    this.onNotificationTap,
    this.notificationCount = 0,
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
            // Info column takes the remaining space; the notification bell
            // and the single chevron (inside _buildInfo) sit at the
            // trailing edge. Previously there was a SECOND chevron here
            // after the bell — removed, since the mockup shows only one.
            Expanded(child: _buildInfo(profile)),
            if (widget.showNotificationBell) ...[
              _buildNotificationIcon(),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildAvatar(Profile? profile) {
    final color = profile?.effectiveColor ?? AppColors.primary;
    final size = widget.isCompact ? 40.0 : 56.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
            ),
            child: Center(
              child: Text(
                profile != null && profile.firstName.isNotEmpty
                    ? profile.firstName.substring(0, 1)
                    : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isCompact ? 16 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Small status dot: only shown for non-validated profiles, since
          // "validated" is the default/expected state and doesn't need a
          // badge cluttering the avatar (profiles have states: PENDING,
          // VALIDATED, REJECTED).
          if (profile != null && profile.statusLabel != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: widget.isCompact ? 12 : 14,
                height: widget.isCompact ? 12 : 14,
                decoration: BoxDecoration(
                  color: profile.statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.getCardBackground(context),
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo(Profile? profile) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  profile?.fullName ?? 'Aucun profil',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: widget.isCompact ? 14 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextMain(context),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: widget.isCompact ? 14 : 20,
                color: AppColors.getTextSecondary(context),
              ),
            ],
          ),
          if (!widget.isCompact && profile != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Flexible(
                  child: Text(
                    // Shows the profile's organization when the user
                    // provided one, otherwise falls back to Interne/Externe
                    // (see Profile.displaySubtitle) — the data model has no
                    // separate "Étudiant/Professionnel/Personnel" field.
                    profile.displaySubtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ),
                if (profile.statusLabel != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: profile.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      profile.statusLabel!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: profile.statusColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onNotificationTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: AppColors.getTextMain(context),
              ),
              if (widget.notificationCount > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.notificationCount > 9 ? '9+' : '${widget.notificationCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
