import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/freelance_dtos.dart';
import '../controllers/freelance_providers.dart';
import '../controllers/freelance_providers_ext.dart';

class JobTemplatesScreen extends ConsumerStatefulWidget {
  const JobTemplatesScreen({super.key});

  @override
  ConsumerState<JobTemplatesScreen> createState() => _JobTemplatesScreenState();
}

class _JobTemplatesScreenState extends ConsumerState<JobTemplatesScreen> {
  final _nameController = TextEditingController();
  String? _categoryId;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_nameController.text.trim().isEmpty || _categoryId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(freelanceRepositoryProvider).createTemplate(
            CreateJobTemplateDto(
              name: _nameController.text.trim(),
              categoryId: _categoryId!,
              defaultCapacity: 1,
              defaultAmount: 0,
              defaultCurrency: 'EUR',
              defaultPaymentType: 2,
              defaultPaymentTiming: 0,
              defaultCheckInMethod: 4,
              defaultRequiresKyc: false,
            ),
          );
      if (!mounted) return;
      ref.invalidate(myTemplatesProvider);
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modèle créé.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String id) async {
    await ref.read(freelanceRepositoryProvider).deleteTemplate(id);
    ref.invalidate(myTemplatesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templatesAsync = ref.watch(myTemplatesProvider);
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mes modèles',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nom du modèle',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (cat) => DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text('Catégorie'),
                items: cat
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Erreur'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _add,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Créer'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: templatesAsync.when(
                data: (templates) => templates.isEmpty
                    ? const Center(child: Text('Aucun modèle.'))
                    : ListView.builder(
                        itemCount: templates.length,
                        itemBuilder: (context, index) {
                          final t = templates[index];
                          return ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(t.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => _remove(t.id),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur : $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}