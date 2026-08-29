import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/freelance_dtos.dart';
import '../../domain/entities/enums.dart';
import '../controllers/freelance_providers.dart';
import '../freelance_labels.dart';

class CreateJobPostingScreen extends ConsumerStatefulWidget {
  const CreateJobPostingScreen({super.key});

  @override
  ConsumerState<CreateJobPostingScreen> createState() =>
      _CreateJobPostingScreenState();
}

class _CreateJobPostingScreenState
    extends ConsumerState<CreateJobPostingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController(text: '1');
  final _amountController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String? _categoryId;
  PaymentType _paymentType = PaymentType.perTask;
  PaymentTiming _paymentTiming = PaymentTiming.payOnCompletion;
  CheckInMethod _checkInMethod = CheckInMethod.any;
  bool _isRemote = false;
  bool _submitting = false;
  DateTime _eventStart = DateTime.now().add(const Duration(days: 7));
  DateTime _eventEnd = DateTime.now().add(const Duration(days: 7, hours: 4));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _amountController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      _toast('Titre requis.');
      return;
    }
    if (_categoryId == null) {
      _toast('Catégorie requise.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final dto = CreateJobPostingDto(
        categoryId: _categoryId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        capacity: int.tryParse(_capacityController.text) ?? 1,
        amount: double.tryParse(_amountController.text) ?? 0,
        currency: 'EUR',
        paymentType: _paymentType.index,
        paymentTiming: _paymentTiming.index,
        checkInMethod: _checkInMethod.index,
        requiresKycVerification: false,
        eventStartAt: _eventStart.toUtc().toIso8601String(),
        eventEndAt: _eventEnd.toUtc().toIso8601String(),
        city: _isRemote ? null : _cityController.text.trim(),
        country: _isRemote ? null : _countryController.text.trim(),
        isRemote: _isRemote,
      );
      await ref.read(freelanceRepositoryProvider).createJobPosting(dto);
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Offre créée (brouillon).'), backgroundColor: Colors.green),
      );
    } catch (e) {
      _toast('Création impossible : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(jobCategoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nouvelle offre',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Titre'),
            _field(_titleController, 'Ex: Serveurs pour gala'),
            const SizedBox(height: 12),
            _label('Description'),
            _field(_descriptionController, 'Décrivez la mission...', maxLines: 4),
            const SizedBox(height: 12),
            _label('Catégorie'),
            categoriesAsync.when(
              data: (cat) => DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: _decoration(isDark),
                items: cat
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Erreur de chargement'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Capacité'),
                      _field(_capacityController, '', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Montant (EUR)'),
                      _field(_amountController, '90', keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label('Type de paiement'),
            _enumDropdown<PaymentType>(
              isDark,
              PaymentType.values,
              _paymentType,
              paymentTypeLabel,
              (v) => setState(() => _paymentType = v),
            ),
            const SizedBox(height: 12),
            _label('Timing de paiement'),
            _enumDropdown<PaymentTiming>(
              isDark,
              PaymentTiming.values,
              _paymentTiming,
              (p) => p == PaymentTiming.escrowUpfront
                  ? 'Escrow à l\'acceptation'
                  : 'À la complétion',
              (v) => setState(() => _paymentTiming = v),
            ),
            const SizedBox(height: 12),
            _label('Méthode de pointage'),
            _enumDropdown<CheckInMethod>(
              isDark,
              CheckInMethod.values,
              _checkInMethod,
              checkInMethodLabel,
              (v) => setState(() => _checkInMethod = v),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isRemote,
              onChanged: (v) => setState(() => _isRemote = v),
              title: const Text('Télétravail'),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isRemote) ...[
              _label('Ville'),
              _field(_cityController, 'Paris'),
              const SizedBox(height: 12),
              _label('Pays'),
              _field(_countryController, 'France'),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Créer (brouillon)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      );

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration _decoration(bool isDark) => InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _enumDropdown<T>(bool isDark, List<T> values, T value,
      String Function(T) label, void Function(T) onChanged) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: _decoration(isDark),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(label(v))))
          .toList(),
      onChanged: (v) => onChanged(v as T),
    );
  }
}