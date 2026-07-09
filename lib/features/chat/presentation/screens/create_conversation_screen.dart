import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/chat_notifier.dart';

class CreateConversationScreen extends ConsumerStatefulWidget {
  const CreateConversationScreen({super.key});

  @override
  ConsumerState<CreateConversationScreen> createState() =>
      _CreateConversationScreenState();
}

class _CreateConversationScreenState
    extends ConsumerState<CreateConversationScreen> {
  final _titleController = TextEditingController();
  List<String> _selectedParticipants = [];
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectContacts() async {
    final result = await context.push<List<String>>('/chat/select-contacts');
    if (result != null) {
      setState(() {
        _selectedParticipants = result;
      });
    }
  }

  Future<void> _create() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez renseigner le titre et sélectionner des participants',
          ),
        ),
      );
      return;
    }

    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _loading = true);
    try {
      final conversation = await ref
          .read(chatNotifierProvider.notifier)
          .createConversation(title, _selectedParticipants);

      if (!mounted) return;
      router.go('/chat/${conversation.id}');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle conversation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la conversation',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedParticipants.isEmpty
                        ? 'Aucun participant sélectionné'
                        : '${_selectedParticipants.length} participant(s) sélectionné(s)',
                    style: TextStyle(
                      color:
                          _selectedParticipants.isEmpty
                              ? Colors.grey
                              : Colors.black,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectContacts,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Sélectionner'),
                ),
              ],
            ),
            if (_selectedParticipants.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _selectedParticipants
                        .map(
                          (id) => Chip(
                            label: Text(id),
                            onDeleted: () {
                              setState(() {
                                _selectedParticipants.remove(id);
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _create,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _loading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Créer la conversation'),
            ),
          ],
        ),
      ),
    );
  }
}
