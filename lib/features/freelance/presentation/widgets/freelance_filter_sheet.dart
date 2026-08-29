import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers.dart';
import '../freelance_labels.dart';

class FreelanceFilterSheet extends ConsumerStatefulWidget {
  const FreelanceFilterSheet({super.key});

  @override
  ConsumerState<FreelanceFilterSheet> createState() =>
      _FreelanceFilterSheetState();
}

class _FreelanceFilterSheetState extends ConsumerState<FreelanceFilterSheet> {
  String? _categoryId;
  final _cityController = TextEditingController();
  bool? _isRemote;
  PaymentType? _paymentType;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtres',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: _reset,
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _sectionTitle('Catégorie'),
                    categoriesAsync.when(
                      data: (categories) => Wrap(
                        spacing: 8,
                        children: categories
                            .map((c) => _chip(c.name, _categoryId == c.id,
                                () => setState(() => _categoryId = c.id)))
                            .toList(),
                      ),
                      loading: () => const Center(
                          child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )),
                      error: (_, __) => const Text('Impossible de charger.'),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Ville'),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Paris',
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF121212) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Type de paiement'),
                    Wrap(
                      spacing: 8,
                      children: PaymentType.values
                          .map((p) => _chip(paymentTypeLabel(p),
                              _paymentType == p,
                              () => setState(() => _paymentType = p)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Distance'),
                    SwitchListTile(
                      value: _isRemote ?? false,
                      onChanged: (v) => setState(
                          () => _isRemote = v ? true : null),
                      title: const Text('Télétravail uniquement'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Appliquer',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
    );
  }

  void _reset() {
    setState(() {
      _categoryId = null;
      _cityController.clear();
      _isRemote = null;
      _paymentType = null;
    });
  }

  void _apply() {
    ref.read(jobSearchProvider.notifier).setFilters(
          categoryId: _categoryId,
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          isRemote: _isRemote,
          paymentType: _paymentType?.index,
        );
    Navigator.of(context).pop();
  }
}