import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/service.dart';
import '../controllers/services_notifier.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  final String? editServiceId;
  const CreateServiceScreen({this.editServiceId, super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  PriceType _priceType = PriceType.FIXED;
  ServiceCategory _category = ServiceCategory.OTHER;
  ServiceScope _scope = ServiceScope.CITY_ONLY;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && widget.editServiceId != null) {
      _loaded = true;
      final state = ref.read(servicesProvider);
      final matched = state.value?.where((s) => s.id == widget.editServiceId);
      final s = (matched == null || matched.isEmpty) ? null : matched.first;
      if (s != null) {
        _titleCtrl.text = s.title;
        _descCtrl.text = s.description;
        _priceCtrl.text = s.price.toStringAsFixed(0);
        _priceType = s.priceType;
        _category = s.category;
        _scope = s.scope;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final payload = {
      if (widget.editServiceId != null) 'id': widget.editServiceId,
      'providerId': 'u_mock',
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim().replaceAll(' ', '')) ?? 0.0,
      'currency': 'EUR',
      'priceType': _priceType.toString().split('.').last,
      'category': _category.toString().split('.').last,
      'images': <String>[],
      'scope': _scope.toString().split('.').last,
      'allowedDepartments': null,
    };

    if (widget.editServiceId != null) {
      await ref.read(servicesProvider.notifier).create(payload);
    } else {
      await ref.read(servicesProvider.notifier).create(payload);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.editServiceId != null ? 'Service mis à jour' : 'Service soumis — en attente de validation')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.editServiceId != null ? 'Modifier le service' : 'Publier un service'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(text: 'Titre du service'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    decoration: _inputDecoration('Ex: Cours de français'),
                  ),
                  const SizedBox(height: 16),
                  _Label(text: 'Description'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: _inputDecoration('Décrivez votre service en détail...'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(text: 'Prix'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('EUR', style: TextStyle(color: AppColors.getTextSecondary(context))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Label(text: 'Type de prix'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: PriceType.values.map((t) {
                      final selected = _priceType == t;
                      return ChoiceChip(
                        label: Text(
                          t == PriceType.FIXED ? 'Fixe' :
                          t == PriceType.PER_HOUR ? 'Par heure' : 'Négociable',
                        ),
                        selected: selected,
                        onSelected: (_) => setState(() => _priceType = t),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.getTextMain(context),
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(text: 'Catégorie'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ServiceCategory>(
                    value: _category,
                    decoration: _inputDecoration(''),
                    items: ServiceCategory.values.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.toString().split('.').last.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v ?? ServiceCategory.OTHER),
                  ),
                  const SizedBox(height: 16),
                  _Label(text: 'Zone de service'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ServiceScope>(
                    value: _scope,
                    decoration: _inputDecoration(''),
                    items: ServiceScope.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s == ServiceScope.CITY_ONLY ? 'Ville uniquement' :
                          s == ServiceScope.COUNTRY_WIDE ? 'National' : 'Départements spécifiques',
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _scope = v ?? ServiceScope.CITY_ONLY),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: Icon(widget.editServiceId != null ? Icons.save_rounded : Icons.send_rounded),
                label: Text(widget.editServiceId != null ? 'Enregistrer' : 'Publier le service'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
      filled: true,
      fillColor: AppColors.getBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.getTextMain(context),
      ),
    );
  }
}
