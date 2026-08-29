import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/availability_slot_model.dart';
import '../../data/models/marketplace_dtos.dart';
import '../../domain/entities/listing.dart';
import '../controllers/marketplace_providers.dart';
import '../widgets/photo_picker_grid.dart';
import '../widgets/availability_widget.dart';

/// Replaces the old single-page 900-line form with a guided 4-step
/// wizard: Photos -> Basics -> Pricing & availability -> Review.
///
/// Rationale: a long form discourages completion and gives no feedback
/// on what's missing. Splitting it into steps with a visible progress
/// bar, per-step validation, and a final recap screen makes publishing
/// feel achievable and reduces abandoned drafts.
class CreateListingWizardScreen extends ConsumerStatefulWidget {
  final String? editListingId;

  const CreateListingWizardScreen({super.key, this.editListingId});

  @override
  ConsumerState<CreateListingWizardScreen> createState() =>
      _CreateListingWizardScreenState();
}

enum _ListingKind { annonce, service }

class _CreateListingWizardScreenState
    extends ConsumerState<CreateListingWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  static const _stepCount = 4;
  static const _stepTitles = ['Photos', 'Informations', 'Prix & dispo', 'Récapitulatif'];

  // Step 1: photos
  final List<String> _localPhotoPaths = [];

  // Step 2: basics
  _ListingKind _kind = _ListingKind.annonce;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  ServiceCategory _serviceCategory = ServiceCategory.other;
  String _categoryId = 'general';

  // Step 3: pricing & availability
  int _paymentMode = 0; // 0 free, 1 fixed, 2 negotiable
  final _priceController = TextEditingController();
  String _currency = 'XOF';
  bool _availableNow = true;
  ServiceScope? _serviceScope;
  PriceType? _priceType;
  List<String> _selectedDepartments = [];

  // Step 4: availability detail
  final List<AvailabilitySlotModel> _availabilitySlots = [];

  bool _isSubmitting = false;

  static const _paymentModes = [
    (0, 'Gratuit', Icons.card_giftcard_rounded),
    (1, 'Prix fixe', Icons.payments_rounded),
    (2, 'Négociable', Icons.handshake_rounded),
  ];

  // French departments for scope DEPARTMENT_LIST
  static const _departments = [
    'Ain', 'Aisne', 'Allier', 'Alpes-de-Haute-Provence', 'Hautes-Alpes',
    'Alpes-Maritimes', 'Ardèche', 'Ardennes', 'Ariège', 'Aube',
    'Aude', 'Aveyron', 'Bouches-du-Rhône', 'Calvados', 'Cantal',
    'Charente', 'Charente-Maritime', 'Cher', 'Corrèze', 'Corse-du-Sud',
    'Haute-Corse', "Côte-d'Or", "Côtes-d'Armor", 'Creuse', 'Deux-Sèvres',
    'Dordogne', 'Doubs', 'Drôme', 'Essonne', 'Eure', 'Eure-et-Loir',
    'Finistère', 'Gard', 'Haute-Garonne', 'Gers', 'Gironde', 'Guadeloupe',
    'Guyane', 'Hérault', 'Ille-et-Vilaine', 'Indre', 'Indre-et-Loire',
    'Isère', 'Jura', 'Landes', 'Loir-et-Cher', 'Loire', 'Haute-Loire',
    'Loire-Atlantique', 'Loiret', 'Lot', 'Lot-et-Garonne', 'Lozère',
    'Maine-et-Loire', 'Manche', 'Marne', 'Haute-Marne', 'Martinique',
    'Mayenne', 'Meurthe-et-Moselle', 'Meuse', 'Morbihan', 'Moselle',
    'Nièvre', 'Nord', 'Oise', 'Orne', 'Paris', 'Pas-de-Calais',
    'Puy-de-Dôme', 'Pyrénées-Atlantiques', 'Hautes-Pyrénées',
    'Pyrénées-Orientales', 'Bas-Rhin', 'Haut-Rhin', 'Rhône',
    'Haute-Saône', 'Saône-et-Loire', 'Sarthe', 'Savoie', 'Haute-Savoie',
    'Seine', 'Seine-Maritime', 'Seine-et-Marne', 'Yvelines', 'Deux-Sèvres',
    'Somme', 'Tarn', 'Tarn-et-Garonne', 'Territoire de Belfort',
    'Val-de-Marne', 'Val-d\'Oise', 'Var', 'Vaucluse', 'Vendée',
    'Vienne', 'Haute-Vienne', 'Vosges', 'Yonne', 'Essonne', 'Guyane',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _localPhotoPaths.isNotEmpty;
      case 1:
        return _titleController.text.trim().length >= 3 &&
            _descriptionController.text.trim().length >= 10;
      case 2:
        if (_paymentMode == 1 && _priceController.text.trim().isEmpty) {
          return false;
        }
        if (_kind == _ListingKind.service) {
          if (_serviceCategory == null) return false;
          if (_priceType == null) return false;
          if (_serviceScope == null) return false;
          if (_serviceScope == ServiceScope.departmentList &&
              _selectedDepartments.isEmpty) {
            return false;
          }
        }
        return true;
      default:
        return true;
    }
  }

  void _goNext() {
    if (!_canContinue) return;
    if (_step == _stepCount - 1) {
      _submit();
      return;
    }
    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: 280.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _goBack() {
    if (_step == 0) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
      return;
    }
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: 280.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _showAvailabilityManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gérer les créneaux', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _availabilitySlots.add(AvailabilitySlotModel(
                              day: DateTime.now().weekday - 1,
                              startTime: '09:00:00',
                              endTime: '18:00:00',
                            ));
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AvailabilityWidget(
                      slots: _availabilitySlots,
                      isAvailableNow: _availableNow,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final dto = CreateListingDto(
        categoryId: _categoryId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        contactInfo: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        paymentMode: _paymentMode,
        price: _paymentMode == 1 && _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        currency: _currency,
        imagePaths: _localPhotoPaths,
        availabilitySlots: _availabilitySlots,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        serviceCategory: _kind == _ListingKind.service ? _serviceCategory : null,
        priceType: _kind == _ListingKind.service ? _priceType : null,
        serviceScope: _kind == _ListingKind.service ? _serviceScope : null,
        allowedDepartments: _kind == _ListingKind.service && _serviceScope == ServiceScope.departmentList
            ? _selectedDepartments
            : null,
        isStandardService: _kind == _ListingKind.service,
      );

      if (widget.editListingId != null) {
        await ref.read(marketplaceRepositoryProvider).updateListing(
              widget.editListingId!,
              UpdateListingDto(
                title: dto.title,
                description: dto.description,
                contactInfo: dto.contactInfo,
                paymentMode: dto.paymentMode,
                price: dto.price,
                currency: dto.currency,
                imagePaths: dto.imagePaths,
                availabilitySlots: dto.availabilitySlots,
                city: dto.city,
                country: dto.country,
                serviceCategory: dto.serviceCategory,
                priceType: dto.priceType,
                serviceScope: dto.serviceScope,
                allowedDepartments: dto.allowedDepartments,
              ),
            );
      } else {
        await ref.read(marketplaceRepositoryProvider).createListing(dto);
      }

      ref.read(marketplaceProvider.notifier).fetch(refresh: true);
      ref.read(servicesProvider.notifier).fetch(refresh: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editListingId != null
              ? 'Annonce mise à jour'
              : 'Annonce publiée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PhotosStep(
                    localPaths: _localPhotoPaths,
                    onAdd: (p) => setState(() => _localPhotoPaths.add(p)),
                    onRemove: (p) => setState(() => _localPhotoPaths.remove(p)),
                  ),
                  _BasicsStep(
                    kind: _kind,
                    onKindChanged: (k) => setState(() => _kind = k),
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    contactController: _contactController,
                    cityController: _cityController,
                    countryController: _countryController,
                    serviceCategory: _serviceCategory,
                    onServiceCategoryChanged: (c) => setState(() => _serviceCategory = c),
                    onChanged: () => setState(() {}),
                  ),
                  _PricingStep(
                    kind: _kind,
                    paymentMode: _paymentMode,
                    paymentModes: _paymentModes,
                    onPaymentModeChanged: (m) => setState(() => _paymentMode = m),
                    priceController: _priceController,
                    currency: _currency,
                    onCurrencyChanged: (c) => setState(() => _currency = c),
                    availableNow: _availableNow,
                    onAvailableNowChanged: (v) => setState(() => _availableNow = v),
                    serviceScope: _serviceScope,
                    onServiceScopeChanged: (s) => setState(() => _serviceScope = s),
                    priceType: _priceType,
                    onPriceTypeChanged: (p) => setState(() => _priceType = p),
                    selectedDepartments: _selectedDepartments,
                    onDepartmentsChanged: (d) => setState(() => _selectedDepartments = d),
                    departments: _departments,
                    onManageAvailability: _showAvailabilityManager,
                    onChanged: () => setState(() {}),
                  ),
                  _ReviewStep(
                    photoCount: _localPhotoPaths.length,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    contact: _contactController.text,
                    city: _cityController.text,
                    country: _countryController.text,
                    kind: _kind,
                    paymentMode: _paymentMode,
                    price: _priceController.text,
                    currency: _currency,
                    serviceCategory: _serviceCategory,
                    priceType: _priceType,
                    serviceScope: _serviceScope,
                    selectedDepartments: _selectedDepartments,
                    availabilitySlotsCount: _availabilitySlots.length,
                  ),
                ],
              ),
            ),
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: _goBack,
            icon: Icon(Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Étape ${_step + 1} sur $_stepCount · ${_stepTitles[_step]}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(_stepCount, (i) {
                    final active = i <= _step;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == _stepCount - 1 ? 0 : 4),
                        height: 3,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : (isDark ? Colors.white12 : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final isLast = _step == _stepCount - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: (_canContinue && !_isSubmitting) ? _goNext : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? Colors.white12 : Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Text(
                isLast ? 'Publier l\'annonce' : 'Continuer',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

// ── Step 1: Photos ──────────────────────────────────────────────────

class _PhotosStep extends StatelessWidget {
  final List<String> localPaths;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _PhotosStep({
    required this.localPaths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajoutez des photos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les annonces avec au moins 3 photos reçoivent bien plus de contacts.',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          PhotoPickerGrid(
            existingUrls: const [],
            localPaths: localPaths,
            onAddLocalPath: onAdd,
            onRemoveExisting: (_) {},
            onRemoveLocal: onRemove,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

// ── Step 2: Basics ──────────────────────────────────────────────────

class _BasicsStep extends StatelessWidget {
  final _ListingKind kind;
  final ValueChanged<_ListingKind> onKindChanged;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contactController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final ServiceCategory serviceCategory;
  final ValueChanged<ServiceCategory> onServiceCategoryChanged;
  final VoidCallback onChanged;

  const _BasicsStep({
    required this.kind,
    required this.onKindChanged,
    required this.titleController,
    required this.descriptionController,
    required this.contactController,
    required this.cityController,
    required this.countryController,
    required this.serviceCategory,
    required this.onServiceCategoryChanged,
    required this.onChanged,
  });

  static const _categoryLabels = {
    ServiceCategory.housing: 'Logement',
    ServiceCategory.transport: 'Transport',
    ServiceCategory.translation: 'Traduction',
    ServiceCategory.administrativeHelp: 'Aide administrative',
    ServiceCategory.groceries: 'Courses',
    ServiceCategory.tutoring: 'Soutien scolaire',
    ServiceCategory.cleaning: 'Ménage',
    ServiceCategory.repair: 'Réparation',
    ServiceCategory.other: 'Autre',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parlez-nous en',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _KindChoiceChip(
                  label: 'Annonce',
                  icon: Icons.storefront_outlined,
                  selected: kind == _ListingKind.annonce,
                  isDark: isDark,
                  onTap: () => onKindChanged(_ListingKind.annonce),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KindChoiceChip(
                  label: 'Service',
                  icon: Icons.handyman_rounded,
                  selected: kind == _ListingKind.service,
                  isDark: isDark,
                  onTap: () => onKindChanged(_ListingKind.service),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _FieldLabel('Titre', isDark),
          TextField(
            controller: titleController,
            onChanged: (_) => onChanged(),
            maxLength: 80,
            decoration: _inputDecoration(isDark, hint: 'Ex : Cours de mathématiques niveau lycée'),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Description', isDark),
          TextField(
            controller: descriptionController,
            onChanged: (_) => onChanged(),
            maxLines: 5,
            decoration: _inputDecoration(isDark, hint: 'Décrivez ce que vous proposez, votre expérience, vos disponibilités...'),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Contact (téléphone / email)', isDark),
          TextField(
            controller: contactController,
            decoration: _inputDecoration(isDark, hint: 'Ex : 06 12 34 56 78 ou email@domaine.com'),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Ville', isDark),
          TextField(
            controller: cityController,
            decoration: _inputDecoration(isDark, hint: 'Ex : Paris'),
          ),
          const SizedBox(height: 12),
          _FieldLabel('Pays', isDark),
          TextField(
            controller: countryController,
            decoration: _inputDecoration(isDark, hint: 'Ex : France'),
          ),
          if (kind == _ListingKind.service) ...[
            const SizedBox(height: 12),
            _FieldLabel('Catégorie de service', isDark),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ServiceCategory.values.map((c) {
                final selected = c == serviceCategory;
                return ChoiceChip(
                  label: Text(_categoryLabels[c] ?? c.name),
                  selected: selected,
                  onSelected: (_) => onServiceCategoryChanged(c),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: selected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  InputDecoration _inputDecoration(bool isDark, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _KindChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _KindChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey[200]!)),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey[500]), size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
      ),
    );
  }
}

// ── Step 3: Pricing & availability ──────────────────────────────────

class _PricingStep extends StatelessWidget {
  final _ListingKind kind;
  final int paymentMode;
  final List<(int, String, IconData)> paymentModes;
  final ValueChanged<int> onPaymentModeChanged;
  final TextEditingController priceController;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final bool availableNow;
  final ValueChanged<bool> onAvailableNowChanged;
  final ServiceScope? serviceScope;
  final ValueChanged<ServiceScope?> onServiceScopeChanged;
  final PriceType? priceType;
  final ValueChanged<PriceType?> onPriceTypeChanged;
  final List<String> selectedDepartments;
  final ValueChanged<List<String>> onDepartmentsChanged;
  final List<String> departments;
  final VoidCallback onManageAvailability;
  final VoidCallback onChanged;

  const _PricingStep({
    required this.kind,
    required this.paymentMode,
    required this.paymentModes,
    required this.onPaymentModeChanged,
    required this.priceController,
    required this.currency,
    required this.onCurrencyChanged,
    required this.availableNow,
    required this.onAvailableNowChanged,
    required this.serviceScope,
    required this.onServiceScopeChanged,
    required this.priceType,
    required this.onPriceTypeChanged,
    required this.selectedDepartments,
    required this.onDepartmentsChanged,
    required this.departments,
    required this.onManageAvailability,
    required this.onChanged,
  });

  static const _scopeLabels = {
    ServiceScope.cityOnly: 'Ma ville uniquement',
    ServiceScope.departmentList: 'Liste de départements',
    ServiceScope.countryWide: 'Tout le pays',
  };

  static const _priceTypeLabels = {
    PriceType.fixed: 'Prix fixe',
    PriceType.perHour: 'Par heure',
    PriceType.negotiable: 'Négociable',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prix et disponibilité',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: paymentModes.map((mode) {
              final selected = paymentMode == mode.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onPaymentModeChanged(mode.$1),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey[200]!)),
                    ),
                    child: Row(
                      children: [
                        Icon(mode.$3, size: 20, color: selected ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey[500])),
                        const SizedBox(width: 12),
                        Text(
                          mode.$2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
                          ),
                        ),
                        const Spacer(),
                        if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (paymentMode == 1) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: priceController,
                    onChanged: (_) => onChanged(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Montant',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: currency,
                    items: const ['XOF', 'EUR', 'USD']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => v != null ? onCurrencyChanged(v) : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (kind == _ListingKind.service) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Options service',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PriceType>(
              value: priceType,
              decoration: _decoration(isDark, 'Type de tarification', Icons.price_change_rounded),
              items: PriceType.values.map((p) => DropdownMenuItem(
                value: p,
                child: Text(_priceTypeLabels[p] ?? p.name, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              )).toList(),
              onChanged: (v) => onPriceTypeChanged(v),
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceScope>(
              value: serviceScope,
              decoration: _decoration(isDark, 'Zone de couverture', Icons.map_rounded),
              items: ServiceScope.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(_scopeLabels[s] ?? s.name, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              )).toList(),
              onChanged: (v) => onServiceScopeChanged(v),
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            if (serviceScope == ServiceScope.departmentList) ...[
              const SizedBox(height: 12),
              _buildDepartmentsSelector(isDark),
            ],
          ],
          const SizedBox(height: 20),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: availableNow,
            onChanged: onAvailableNowChanged,
            activeThumbColor: AppColors.primary,
            title: Text(
              'Disponible dès maintenant',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ),
            subtitle: Text(
              'Vous pourrez affiner votre calendrier plus tard via "Gérer les créneaux"',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onManageAvailability,
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: const Text('Gérer les créneaux détaillés'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
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
          children: departments.map((dept) {
            final selected = selectedDepartments.contains(dept);
            return FilterChip(
              label: Text(dept, style: TextStyle(fontSize: 11)),
              selected: selected,
              onSelected: (sel) {
                final newList = List<String>.from(selectedDepartments);
                if (sel) {
                  newList.add(dept);
                } else {
                  newList.remove(dept);
                }
                onDepartmentsChanged(newList);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              showCheckmark: false,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
        if (selectedDepartments.isEmpty)
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

  InputDecoration _decoration(bool isDark, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _ReviewRow({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 17, color: isDark ? Colors.white54 : Colors.grey[500]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final int photoCount;
  final String title;
  final String description;
  final String contact;
  final String city;
  final String country;
  final _ListingKind kind;
  final int paymentMode;
  final String price;
  final String currency;
  final ServiceCategory? serviceCategory;
  final PriceType? priceType;
  final ServiceScope? serviceScope;
  final List<String> selectedDepartments;
  final int availabilitySlotsCount;

  const _ReviewStep({
    required this.photoCount,
    required this.title,
    required this.description,
    required this.contact,
    required this.city,
    required this.country,
    required this.kind,
    required this.paymentMode,
    required this.price,
    required this.currency,
    this.serviceCategory,
    this.priceType,
    this.serviceScope,
    required this.selectedDepartments,
    required this.availabilitySlotsCount,
  });

  static const _scopeLabels = {
    ServiceScope.cityOnly: 'Ma ville uniquement',
    ServiceScope.departmentList: 'Liste de départements',
    ServiceScope.countryWide: 'Tout le pays',
  };

  static const _priceTypeLabels = {
    PriceType.fixed: 'Prix fixe',
    PriceType.perHour: 'Par heure',
    PriceType.negotiable: 'Négociable',
  };

  static const _categoryLabels = {
    ServiceCategory.housing: 'Logement',
    ServiceCategory.transport: 'Transport',
    ServiceCategory.translation: 'Traduction',
    ServiceCategory.administrativeHelp: 'Aide administrative',
    ServiceCategory.groceries: 'Courses',
    ServiceCategory.tutoring: 'Soutien scolaire',
    ServiceCategory.cleaning: 'Ménage',
    ServiceCategory.repair: 'Réparation',
    ServiceCategory.other: 'Autre',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceLabel = paymentMode == 0
        ? 'Gratuit'
        : (paymentMode == 2 ? 'Négociable' : '${price.isEmpty ? '—' : price} $currency');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dernière vérification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vérifiez les informations avant de publier.',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewRow(icon: Icons.photo_camera_outlined, label: '$photoCount photo${photoCount > 1 ? 's' : ''}', isDark: isDark),
                _ReviewRow(icon: Icons.title_rounded, label: title.isEmpty ? 'Sans titre' : title, isDark: isDark),
                _ReviewRow(
                  icon: kind == _ListingKind.annonce ? Icons.storefront_outlined : Icons.handyman_rounded,
                  label: kind == _ListingKind.annonce ? 'Annonce' : 'Service',
                  isDark: isDark,
                ),
                _ReviewRow(icon: Icons.payments_outlined, label: priceLabel, isDark: isDark),
                if (city.isNotEmpty) _ReviewRow(icon: Icons.location_on_outlined, label: city, isDark: isDark),
                if (country.isNotEmpty) _ReviewRow(icon: Icons.public_outlined, label: country, isDark: isDark),
                if (kind == _ListingKind.service) ...[
                  _ReviewRow(icon: Icons.category_outlined, label: _categoryLabels[serviceCategory] ?? '—', isDark: isDark),
                  _ReviewRow(icon: Icons.price_change_outlined, label: _priceTypeLabels[priceType] ?? '—', isDark: isDark),
                  _ReviewRow(icon: Icons.map_outlined, label: _scopeLabels[serviceScope] ?? '—', isDark: isDark),
                  if (serviceScope == ServiceScope.departmentList)
                    _ReviewRow(icon: Icons.map_outlined, label: '${selectedDepartments.length} département${selectedDepartments.length > 1 ? 's' : ''}', isDark: isDark),
                ],
                const Divider(height: 24),
                _ReviewRow(icon: Icons.description_outlined, label: description.isEmpty ? 'Aucune description.' : description, isDark: isDark),
                if (contact.isNotEmpty)
                  _ReviewRow(icon: Icons.contact_phone_outlined, label: contact, isDark: isDark),
                _ReviewRow(icon: Icons.calendar_today_outlined, label: '$availabilitySlotsCount créneau${availabilitySlotsCount > 1 ? 'x' : ''}', isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre annonce sera visible après une courte modération.',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
