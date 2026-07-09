import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/committee_notifiers.dart';

class ProposalsScreen extends ConsumerStatefulWidget {
  final String committeeId;

  const ProposalsScreen({super.key, required this.committeeId});

  @override
  ConsumerState<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends ConsumerState<ProposalsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreatingProposal = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(
      committeeProposalsProvider(widget.committeeId),
    );
    final proposalsNotifier = ref.read(
      committeeProposalsProvider(widget.committeeId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propositions du Comité'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => _showCreateProposalDialog(context, proposalsNotifier),
          ),
        ],
      ),
      body: proposalsAsync.when(
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
                          committeeProposalsProvider(widget.committeeId),
                        ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
        data:
            (proposals) =>
                proposals.isEmpty
                    ? const Center(child: Text('Aucune proposition'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: proposals.length,
                      itemBuilder: (context, index) {
                        final proposal = proposals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        proposal.title,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          proposal.status,
                                        ).withAlpha((0.1 * 255).round()),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusDisplayName(proposal.status),
                                        style: TextStyle(
                                          color: _getStatusColor(
                                            proposal.status,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  proposal.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Proposé par: Utilisateur ${proposal.proposerId.split('_').last}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Soumis le ${_formatDate(proposal.submittedAt)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                if (proposal.votes.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Votes (${proposal.votes.length}):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children:
                                        proposal.votes
                                            .map(
                                              (vote) => Chip(
                                                label: Text(
                                                  '${_getVoteDisplayName(vote.vote)} (Utilisateur ${vote.voterId.split('_').last})',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor: _getVoteColor(
                                                  vote.vote,
                                                ).withValues(alpha: 0.1),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                                if (proposal.decision != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Décision',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          proposal.decision!,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (proposal.status == 'PENDING' ||
                                    proposal.status == 'UNDER_REVIEW') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              () => _voteOnProposal(
                                                proposalsNotifier,
                                                proposal.id,
                                                'YES',
                                              ),
                                          icon: const Icon(
                                            Icons.thumb_up,
                                            size: 16,
                                          ),
                                          label: const Text('Pour'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              () => _voteOnProposal(
                                                proposalsNotifier,
                                                proposal.id,
                                                'NO',
                                              ),
                                          icon: const Icon(
                                            Icons.thumb_down,
                                            size: 16,
                                          ),
                                          label: const Text('Contre'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              () => _voteOnProposal(
                                                proposalsNotifier,
                                                proposal.id,
                                                'ABSTAIN',
                                              ),
                                          icon: const Icon(
                                            Icons.horizontal_rule,
                                            size: 16,
                                          ),
                                          label: const Text('Abstention'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }

  void _showCreateProposalDialog(
    BuildContext context,
    CommitteeProposalsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nouvelle Proposition'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Entrez le titre de la proposition',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez la proposition en détail',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed:
                    _isCreatingProposal
                        ? null
                        : () => _createProposal(context, notifier),
                child:
                    _isCreatingProposal
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Créer'),
              ),
            ],
          ),
    );
  }

  Future<void> _createProposal(
    BuildContext context,
    CommitteeProposalsNotifier notifier,
  ) async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isCreatingProposal = true);

    final messenger = ScaffoldMessenger.of(context);
    try {
      await notifier.createProposal(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );

      if (mounted) {
        context.pop();
        _titleController.clear();
        _descriptionController.clear();
        messenger.showSnackBar(
          const SnackBar(content: Text('Proposition créée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingProposal = false);
      }
    }
  }

  Future<void> _voteOnProposal(
    CommitteeProposalsNotifier notifier,
    String proposalId,
    String vote,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await notifier.voteOnProposal(proposalId, vote);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Vote enregistré')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Erreur lors du vote: $e')),
        );
      }
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'UNDER_REVIEW':
        return 'En révision';
      case 'APPROVED':
        return 'Approuvée';
      case 'REJECTED':
        return 'Rejetée';
      case 'IMPLEMENTED':
        return 'Implémentée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'IMPLEMENTED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getVoteDisplayName(String vote) {
    switch (vote) {
      case 'YES':
        return 'Pour';
      case 'NO':
        return 'Contre';
      case 'ABSTAIN':
        return 'Abstention';
      default:
        return vote;
    }
  }

  Color _getVoteColor(String vote) {
    switch (vote) {
      case 'YES':
        return Colors.green;
      case 'NO':
        return Colors.red;
      case 'ABSTAIN':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
