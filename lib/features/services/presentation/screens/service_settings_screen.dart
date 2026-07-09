import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../domain/entities/service.dart';

class ServiceSettingsScreen extends StatefulWidget {
  const ServiceSettingsScreen({super.key});

  @override
  State<ServiceSettingsScreen> createState() => _ServiceSettingsScreenState();
}

class _ServiceSettingsScreenState extends State<ServiceSettingsScreen> {
  String _selectedPaymentMethod = 'Carte bancaire';
  final Set<ServiceCategory> _selectedCategories = {ServiceCategory.TUTORING, ServiceCategory.ADMINISTRATIVE_HELP};
  ServiceScope _selectedScope = ServiceScope.CITY_ONLY;

  final _paymentMethods = ['Carte bancaire', 'Mobile Money', 'Virement', 'Espèces'];
  final _allCategories = ServiceCategory.values;
  final _scopeOptions = <ServiceScope>[ServiceScope.CITY_ONLY, ServiceScope.DEPARTMENT_LIST, ServiceScope.COUNTRY_WIDE];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileSection(context),
                  const SizedBox(height: 20),
                  _SettingsModalTile(
                    icon: Icons.payments_outlined,
                    title: 'Moyen de paiement',
                    value: _selectedPaymentMethod,
                    onTap: () => _showPaymentPicker(context),
                  ),
                  const SizedBox(height: 8),
                  _SettingsModalTile(
                    icon: Icons.category_outlined,
                    title: 'Catégories',
                    value: _selectedCategories.isEmpty ? 'Aucune' : '${_selectedCategories.length} sélectionnée(s)',
                    onTap: () => _showCategoriesPicker(context),
                  ),
                  const SizedBox(height: 8),
                  _SettingsModalTile(
                    icon: Icons.location_on_outlined,
                    title: 'Zone de service',
                    value: _selectedScope == ServiceScope.CITY_ONLY ? 'Ville uniquement' :
                            _selectedScope == ServiceScope.COUNTRY_WIDE ? 'National' : 'Départements spécifiques',
                    onTap: () => _showScopePicker(context),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Diaspora Services v1.0',
                      style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jean Dupont',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prestataire de services',
                  style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: prov_1 | Membre depuis janvier 2026',
                  style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionSheet(
        title: 'Moyen de paiement',
        options: _paymentMethods,
        selected: _selectedPaymentMethod,
        isSingle: true,
        onSelected: (v) {
          setState(() => _selectedPaymentMethod = v as String);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showCategoriesPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final localSelected = Set<ServiceCategory>.from(_selectedCategories);
          return _OptionSheet(
            title: 'Catégories',
            options: _allCategories.map((c) => c.toString().split('.').last.replaceAll('_', ' ')).toList(),
            selected: '',
            isSingle: false,
            multiSelected: _allCategories.map((c) => _selectedCategories.contains(c)).toList(),
            onMultiToggle: (i) {
              final cat = _allCategories[i];
              setState(() {
                if (_selectedCategories.contains(cat)) {
                  _selectedCategories.remove(cat);
                } else {
                  _selectedCategories.add(cat);
                }
              });
              setSheetState(() {});
            },
            onDone: () => Navigator.pop(ctx),
          );
        },
      ),
    );
  }

  void _showScopePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionSheet(
        title: 'Zone de service',
        options: _scopeOptions.map((s) => s == ServiceScope.CITY_ONLY ? 'Ville uniquement' :
                s == ServiceScope.COUNTRY_WIDE ? 'National' : 'Départements spécifiques').toList(),
        selected: '',
        isSingle: true,
        scopeSelected: _selectedScope,
        onSelected: (v) {
          setState(() => _selectedScope = v as ServiceScope);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _SettingsModalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsModalTile({required this.icon, required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondary(context), size: 20),
          ],
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final bool isSingle;
  final List<bool>? multiSelected;
  final void Function(dynamic)? onSelected;
  final void Function(int)? onMultiToggle;
  final VoidCallback? onDone;
  final ServiceScope? scopeSelected;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.isSingle,
    this.multiSelected,
    this.onSelected,
    this.onMultiToggle,
    this.onDone,
    this.scopeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scopeOptions = <ServiceScope>[ServiceScope.CITY_ONLY, ServiceScope.DEPARTMENT_LIST, ServiceScope.COUNTRY_WIDE];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
                const Spacer(),
                if (!isSingle)
                  TextButton(
                    onPressed: onDone,
                    child: const Text('Terminé'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(options.length, (i) {
              final isSelected = isSingle
                  ? (scopeSelected != null
                      ? scopeSelected == scopeOptions[i]
                      : selected == options[i])
                  : (multiSelected?[i] ?? false);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.getTextSecondary(context).withValues(alpha: 0.4), width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                  title: Text(
                    options[i],
                    style: TextStyle(fontSize: 14, color: AppColors.getTextMain(context)),
                  ),
                  onTap: () {
                    if (isSingle) {
                      if (scopeSelected != null) {
                        onSelected?.call(scopeOptions[i]);
                      } else {
                        onSelected?.call(options[i]);
                      }
                    } else {
                      onMultiToggle?.call(i);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
