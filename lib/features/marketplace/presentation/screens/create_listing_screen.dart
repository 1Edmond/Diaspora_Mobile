import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/marketplace_dtos.dart';
import '../../domain/entities/listing.dart';
import '../controllers/marketplace_providers.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final String? editListingId;

  const CreateListingScreen({super.key, this.editListingId});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

enum _ListingType { annonce, service }

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  _ListingType _type = _ListingType.annonce;
  int _paymentMode = 0;
  String? _currency = 'XOF';
  bool _isSubmitting = false;

  // Service-specific fields
  ServiceCategory? _serviceCategory;
  PriceType? _priceType;
  ServiceScope? _serviceScope;
  final List<String> _selectedDepartments = [];

  static const _paymentModes = [
    (0, 'Gratuit', Icons.card_giftcard_rounded),
    (1, 'Prix fixe', Icons.payments_rounded),
    (2, 'Négociable', Icons.handshake_rounded),
  ];

  static const _serviceCategories = ServiceCategory.values;
  static const _priceTypes = PriceType.values;
  static const _serviceScopes = ServiceScope.values;

  // French departments for scope DEPARTMENT_LIST
  static const _departments = [
    'Ain',
    'Aisne',
    'Allier',
    'Alpes-de-Haute-Provence',
    'Hautes-Alpes',
    'Alpes-Maritimes',
    'Ardèche',
    'Ardennes',
    'Ariège',
    'Aube',
    'Aude',
    'Aveyron',
    'Bouches-du-Rhône',
    'Calvados',
    'Cantal',
    'Charente',
    'Charente-Maritime',
    'Cher',
    'Corrèze',
    'Corse-du-Sud',
    'Haute-Corse',
    "Côte-d'Or",
    "Côtes-d'Armor",
    'Creuse',
    'Deux-Sèvres',
    'Dordogne',
    'Doubs',
    'Drôme',
    'Essonne',
    'Eure',
    'Eure-et-Loir',
    'Finistère',
    'Gard',
    'Haute-Garonne',
    'Gers',
    'Gironde',
    'Guadeloupe',
    'Guyane',
    'Hérault',
    'Ille-et-Vilaine',
    'Indre',
    'Indre-et-Loire',
    'Isère',
    'Jura',
    'Landes',
    'Loir-et-Cher',
    'Loire',
    'Haute-Loire',
    'Loire-Atlantique',
    'Loiret',
    'Lot',
    'Lot-et-Garonne',
    'Lozère',
    'Maine-et-Loire',
    'Manche',
    'Marne',
    'Haute-Marne',
    'Martinique',
    'Mayenne',
    'Meurthe-et-Moselle',
    'Meuse',
    'Morbihan',
    'Moselle',
    'Nièvre',
    'Nord',
    'Oise',
    'Orne',
    'Paris',
    'Pas-de-Calais',
    'Puy-de-Dôme',
    'Pyrénées-Atlantiques',
    'Hautes-Pyrénées',
    'Pyrénées-Orientales',
    'Bas-Rhin',
    'Haut-Rhin',
    'Rhône',
    'Haute-Saône',
    'Saône-et-Loire',
    'Sarthe',
    'Savoie',
    'Haute-Savoie',
    'Seine',
    'Seine-Maritime',
    'Seine-et-Marne',
    'Yvelines',
    'Deux-Sèvres',
    'Somme',
    'Somme',
    'Somme',
    'Somme',
    'Somme',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final dto = CreateListingDto(
        categoryId:
            _type == _ListingType.service
                ? _serviceCategory?.name.toLowerCase() ?? 'other'
                : 'general',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        contactInfo:
            _contactController.text.trim().isEmpty
                ? null
                : _contactController.text.trim(),
        paymentMode: _paymentMode,
        price:
            _paymentMode == 1 && _priceController.text.isNotEmpty
                ? double.tryParse(_priceController.text)
                : null,
        currency: _currency,
        imagePaths: [],
        availabilitySlots: [],
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
        country:
            _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
        serviceCategory:
            _type == _ListingType.service ? _serviceCategory : null,
        priceType: _type == _ListingType.service ? _priceType : null,
        serviceScope: _type == _ListingType.service ? _serviceScope : null,
        allowedDepartments:
            _type == _ListingType.service &&
                    _serviceScope == ServiceScope.departmentList
                ? _selectedDepartments
                : null,
        isStandardService: _type == _ListingType.service,
      );

      await ref.read(marketplaceRepositoryProvider).createListing(dto);

      if (!mounted) return;
      ref.read(myListingsProvider.notifier).fetch(refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _type == _ListingType.service
                ? 'Service publié ! En attente de modération.'
                : 'Annonce publiée ! En attente de modération.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.editListingId != null
              ? 'Modifier l\'annonce'
              : 'Publier une annonce',
          style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _buildTypeSelector(isDark),
            const SizedBox(height: 16),
            _section('Informations principales', isDark),
            const SizedBox(height: 10),
            _card(
              isDark: isDark,
              color: cardColor,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    maxLength: 80,
                    style: TextStyle(color: textColor),
                    decoration: _decoration(
                      _type == _ListingType.annonce
                          ? 'Titre de l\'annonce'
                          : 'Titre du service',
                      Icons.title_rounded,
                      isDark,
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Titre requis'
                                : null,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 1000,
                    style: TextStyle(color: textColor),
                    decoration: _decoration(
                      _type == _ListingType.annonce
                          ? 'Décrivez votre annonce en détail...'
                          : 'Décrivez votre service en détail...',
                      Icons.description_rounded,
                      isDark,
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().length < 20)
                                ? 'Minimum 20 caractères'
                                : null,
                  ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section('Tarification', isDark),
            const SizedBox(height: 10),
            _card(
              isDark: isDark,
              color: cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _paymentModes.map((mode) {
                          final selected = _paymentMode == mode.$1;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  mode.$3,
                                  size: 16,
                                  color:
                                      selected
                                          ? AppColors.primary
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(mode.$2),
                              ],
                            ),
                            selected: selected,
                            onSelected:
                                (_) => setState(() => _paymentMode = mode.$1),
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color:
                                  selected
                                      ? AppColors.primary
                                      : Colors.grey[600],
                            ),
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            checkmarkColor: AppColors.primary,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    selected
                                        ? AppColors.primary
                                        : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (child, anim) => SizeTransition(
                          sizeFactor: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                    child:
                        _paymentMode == 1
                            ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: textColor),
                                      decoration: _decoration(
                                        'Prix',
                                        Icons.attach_money_rounded,
                                        isDark,
                                      ),
                                      validator: (v) {
                                        if (_paymentMode != 1) return null;
                                        final p = double.tryParse(v ?? '');
                                        return (p == null || p <= 0)
                                            ? 'Prix invalide'
                                            : null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  DropdownButton<String>(
                                    value: _currency,
                                    underline: const SizedBox.shrink(),
                                    items:
                                        ['XOF', 'EUR', 'USD']
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(
                                                  c,
                                                  style: TextStyle(
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        (v) => setState(() => _currency = v),
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  if (_type == _ListingType.service) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Options service',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildServiceCategorySelector(isDark),
                    const SizedBox(height: 12),
                    _buildPriceTypeSelector(isDark),
                    const SizedBox(height: 12),
                    _buildServiceScopeSelector(isDark),
                    if (_serviceScope == ServiceScope.departmentList) ...[
                      const SizedBox(height: 12),
                      _buildDepartmentsSelector(isDark),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section('Localisation & contact', isDark),
            const SizedBox(height: 10),
            _card(
              isDark: isDark,
              color: cardColor,
              child: Column(
                children: [
                  TextFormField(
                    controller: _cityController,
                    style: TextStyle(color: textColor),
                    decoration: _decoration(
                      'Ville (optionnel)',
                      Icons.location_city_rounded,
                      isDark,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _countryController,
                    style: TextStyle(color: textColor),
                    decoration: _decoration(
                      'Pays (optionnel)',
                      Icons.public_rounded,
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactController,
                    style: TextStyle(color: textColor),
                    decoration: _decoration(
                      'Contact (téléphone / email)',
                      Icons.contact_phone_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon:
                    _isSubmitting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.rocket_launch_rounded),
                label: Text(
                  _isSubmitting ? 'Publication...' : 'Publier',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 300.ms, delay: 200.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: 'Annonce',
              icon: Icons.storefront_outlined,
              description: 'Vendre, louer, donner...',
              isSelected: _type == _ListingType.annonce,
              onTap: () => setState(() => _type = _ListingType.annonce),
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _TypeTab(
              label: 'Service',
              icon: Icons.handyman_rounded,
              description: 'Prestation, savoir-faire...',
              isSelected: _type == _ListingType.service,
              onTap: () => setState(() => _type = _ListingType.service),
              isDark: isDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildServiceCategorySelector(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return DropdownButtonFormField<ServiceCategory>(
      value: _serviceCategory,
      decoration: _decoration(
        'Catégorie de service',
        Icons.category_rounded,
        isDark,
      ),
      items:
          _serviceCategories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(
                    _categoryDisplayName(c),
                    style: TextStyle(color: textColor),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _serviceCategory = v),
      validator:
          (v) =>
              _type == _ListingType.service && v == null
                  ? 'Catégorie requise'
                  : null,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }

  Widget _buildPriceTypeSelector(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return DropdownButtonFormField<PriceType>(
      value: _priceType,
      decoration: _decoration(
        'Type de tarification',
        Icons.price_change_rounded,
        isDark,
      ),
      items:
          _priceTypes
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    _priceTypeDisplayName(p),
                    style: TextStyle(color: textColor),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _priceType = v),
      validator:
          (v) =>
              _type == _ListingType.service && v == null ? 'Type requis' : null,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }

  Widget _buildServiceScopeSelector(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    return DropdownButtonFormField<ServiceScope>(
      value: _serviceScope,
      decoration: _decoration('Zone de couverture', Icons.map_rounded, isDark),
      items:
          _serviceScopes
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    _scopeDisplayName(s),
                    style: TextStyle(color: textColor),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _serviceScope = v),
      validator:
          (v) =>
              _type == _ListingType.service && v == null
                  ? 'Portée requise'
                  : null,
      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }

  Widget _buildDepartmentsSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Départements couverts',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              _departments.map((dept) {
                final selected = _selectedDepartments.contains(dept);
                return FilterChip(
                  label: Text(dept, style: TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _selectedDepartments.add(dept);
                      } else {
                        _selectedDepartments.remove(dept);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  showCheckmark: false,
                  backgroundColor:
                      isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  labelStyle: TextStyle(
                    color:
                        selected
                            ? AppColors.primary
                            : (isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                  side: BorderSide(
                    color:
                        selected
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
        ),
        if (_selectedDepartments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Sélectionnez au moins un département',
              style: TextStyle(fontSize: 11, color: Colors.red[400]),
            ),
          ),
      ],
    );
  }

  String _categoryDisplayName(ServiceCategory c) {
    switch (c) {
      case ServiceCategory.housing:
        return 'Logement';
      case ServiceCategory.transport:
        return 'Transport';
      case ServiceCategory.translation:
        return 'Traduction';
      case ServiceCategory.administrativeHelp:
        return 'Aide administrative';
      case ServiceCategory.groceries:
        return 'Courses';
      case ServiceCategory.tutoring:
        return 'Soutien scolaire';
      case ServiceCategory.cleaning:
        return 'Ménage';
      case ServiceCategory.repair:
        return 'Réparation';
      case ServiceCategory.other:
        return 'Autre';
    }
  }

  String _priceTypeDisplayName(PriceType p) {
    switch (p) {
      case PriceType.fixed:
        return 'Prix fixe';
      case PriceType.perHour:
        return 'Par heure';
      case PriceType.negotiable:
        return 'Négociable';
    }
  }

  String _scopeDisplayName(ServiceScope s) {
    switch (s) {
      case ServiceScope.cityOnly:
        return 'Ma ville uniquement';
      case ServiceScope.departmentList:
        return 'Liste de départements';
      case ServiceScope.countryWide:
        return 'Tout le pays';
    }
  }

  Widget _section(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.08, end: 0);
  }

  Widget _card({
    required bool isDark,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }

  InputDecoration _decoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: isDark ? Colors.white38 : Colors.grey[500],
      ),
      filled: true,
      fillColor: isDark ? Colors.black26 : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      counterText: '',
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Colors.white
                      : (isDark ? Colors.white60 : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color:
                    isSelected
                        ? Colors.white70
                        : (isDark ? Colors.white38 : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
