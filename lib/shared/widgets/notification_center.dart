import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/notifications_provider.dart';

class NotificationCenter extends ConsumerWidget {
  final String target;
  const NotificationCenter({required this.target, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    return state.when(
      data:
          (list) => ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = list[i];
              return ListTile(
                title: Text(n['title'] ?? ''),
                subtitle: Text(n['body'] ?? ''),
                trailing:
                    (n['read'] == true)
                        ? const Icon(Icons.check, size: 16)
                        : null,
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error loading notifications')),
    );
  }
}
