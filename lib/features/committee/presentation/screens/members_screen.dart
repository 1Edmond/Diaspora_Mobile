import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/committee_notifiers.dart';

class MembersScreen extends ConsumerWidget {
  final String committeeId;

  const MembersScreen({super.key, required this.committeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(committeeMembersProvider(committeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membres du Comité'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(
                          committeeMembersProvider(committeeId),
                        ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
        data:
            (members) =>
                members.isEmpty
                    ? const Center(child: Text('Aucun membre dans ce comité'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              child: Text(
                                member.role == 'CHAIRPERSON'
                                    ? '👑'
                                    : member.role == 'SECRETARY'
                                    ? '📝'
                                    : '👤',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              'Utilisateur ${member.userId.split('_').last}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getRoleDisplayName(member.role),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Membre depuis ${_formatDate(member.joinedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    member.status == 'ACTIVE'
                                        ? Colors.green.withAlpha(
                                          (0.1 * 255).round(),
                                        )
                                        : Colors.red.withAlpha(
                                          (0.1 * 255).round(),
                                        ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                member.status == 'ACTIVE' ? 'Actif' : 'Inactif',
                                style: TextStyle(
                                  color:
                                      member.status == 'ACTIVE'
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'CHAIRPERSON':
        return 'Président';
      case 'SECRETARY':
        return 'Secrétaire';
      case 'MEMBER':
        return 'Membre';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
