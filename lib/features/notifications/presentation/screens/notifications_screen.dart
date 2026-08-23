import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../shared/widgets/diaspora_app_bar.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../../core/realtime/sse_reconnect_service.dart';
import '../providers/notifications_providers.dart';
import '../providers/sse_provider.dart';
import '../widgets/notification_list_item.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).valueOrNull;
      final target = user?.id ?? 'user1';
      ref.read(notificationsStateProvider.notifier).fetchNotifications(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsStateProvider);
    final connState = ref.watch(sseConnectionProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final unreadLabel = unreadCount > 0 ? ' ($unreadCount)' : '';

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, connState, unreadLabel),
                Expanded(
                  child: notificationsState.when(
                    data: (notifications) {
                      if (notifications.isEmpty) return _buildEmptyState(context);
                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NotificationListItem(
                                  notification: notification,
                                  onTap: () {
                                    if (!notification.isRead) {
                                      ref
                                          .read(
                                            notificationsStateProvider.notifier,
                                          )
                                          .markAsRead(notification.id);
                                    }
                                    _handleNotificationTap(notification);
                                  },
                                )
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .slideX(begin: 0.05),
                          );
                        },
                      );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => Center(child: Text('Erreur: $error')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, SseConnectionState connState, String unreadLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: DiasporaAppBar(
        title: 'Notifications$unreadLabel',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (connState != SseConnectionState.connected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 18,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            NeumorphicContainer(
              width: 40,
              height: 40,
              borderRadius: 20,
              child: IconButton(
                icon: Icon(
                  Icons.clear_all_rounded,
                  color: AppColors.getTextMain(context),
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicContainer(
            width: 100,
            height: 100,
            borderRadius: 50,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tout est calme ici',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextMain(context),
            ),
          ),
          Text(
            'Aucune nouvelle notification.',
            style: TextStyle(color: AppColors.getTextSecondary(context)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  void _handleNotificationTap(notification) {
    // Basic navigation logic
  }
}
