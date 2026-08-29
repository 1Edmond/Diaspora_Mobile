import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/freelance_dtos.dart';
import '../../data/models/job_category_model.dart';
import '../controllers/freelance_providers.dart';
import '../controllers/freelance_providers_ext.dart';

class JobPreferencesScreen extends ConsumerStatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  ConsumerState<JobPreferencesScreen> createState() =>
      _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends ConsumerState<JobPreferencesScreen> {
  String? _categoryId;
  final _cityController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_categoryId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(freelanceRepositoryProvider).createJobPreference(
            CreateJobPreferenceDto(
              categoryId: _categoryId!,
              city: _cityController.text.trim().isEmpty
                  ? null
                  : _cityController.text.trim(),
            ),
          );
      if (!mounted) return;
      ref.invalidate(myJobPreferencesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerte créée.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String id) async {
    await ref.read(freelanceRepositoryProvider).deleteJobPreference(id);
    ref.invalidate(myJobPreferencesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(jobCategoriesProvider);
    final prefsAsync = ref.watch(myJobPreferencesProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mes alertes',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                hint: const Text('Choisir une catégorie'),
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
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Ville (optionnelle)',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _add,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Ajouter'),
            ),
            const SizedBox(height: 16),
            const Text('Le filtre par distance arrive bientôt.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: prefsAsync.when(
                data: (prefs) => prefs.isEmpty
                    ? const Center(child: Text('Aucune alerte.'))
                    : ListView.builder(
                        itemCount: prefs.length,
                        itemBuilder: (context, index) {
                          final p = prefs[index];
                          final catName = ref
                                  .watch(jobCategoriesProvider)
                                  .maybeMap(
                                    data: (d) => d.value.firstWhere(
                                      (c) => c.id == p.categoryId,
                                      orElse: () => JobCategoryModel(
                                        id: p.categoryId,
                                        name: p.categoryId,
                                        isActive: true,
                                      ),
                                    ).name,
                                    orElse: () => p.categoryId,
                                  );
                          return ListTile(
                            leading: const Icon(Icons.notifications_active_rounded),
                            title: Text(catName),
                            subtitle: p.city != null ? Text(p.city!) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => _remove(p.id),
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