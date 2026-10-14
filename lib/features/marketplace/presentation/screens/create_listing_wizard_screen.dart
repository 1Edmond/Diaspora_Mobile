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

/// Guided 4-step wizard for creating a listing or parcel transport service:
/// Step 1: Category & Corridor (Displays Category FIRST as requested)
/// Step 2: Details & Schedule
/// Step 3: Pricing & Capacity (Photos optional for transport)
/// Step 4: Summary & Submit
class CreateListingWizardScreen extends ConsumerStatefulWidget {
  final String? editListingId;

  const CreateListingWizardScreen({super.key, this.editListingId});

  @override
  ConsumerState<CreateListingWizardScreen> createState() =>
      _CreateListingWizardScreenState();
}

enum _ListingKind { service, annonce }

class _CreateListingWizardScreenState
    extends ConsumerState<CreateListingWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  static const _stepCount = 4;
  static const _stepTitles = [
    'Catégorie',
    'Détails',
    'Tarif & Capacité',
    'Récapitulatif'
  ];

  // Category & Kind
  _ListingKind _kind = _ListingKind.service;
  ServiceCategory _serviceCategory = ServiceCategory.transport;
  String _categoryId = 'transport-colis';

  // Travel / Corridor fields
  final _departureCountryController = TextEditingController(text: 'TG');
  final _departureCityController = TextEditingController(text: 'Lomé');
  final _arrivalCountryController = TextEditingController(text: 'RU');
  final _arrivalCityController = TextEditingController(text: 'Moscou');
  DateTime? _departureDate;
  DateTime? _arrivalDate;
  DateTime? _pickupDeadline;
  final _capacityController = TextEditingController(text: '20');
  final _pricePerKgController = TextEditingController(text: '1000');
  final _transportModeController = TextEditingController(text: 'Avion');
  final _flightNumberController = TextEditingController();
  final _prohibitedItemsController = TextEditingController();
  final _meetingPointsController = TextEditingController();

  // General listing fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'TG');
  final _priceController = TextEditingController();
  int _paymentMode = 1; // 0: gratuit, 1: fixe, 2: négociable
  String _currency = 'XOF';
  bool _availableNow = true;
  ServiceScope _serviceScope = ServiceScope.countryWide;
  PriceType _priceType = PriceType.fixed;
  List<String> _selectedDepartments = [];

  // Photos & availability
  final List<String> _localPhotoPaths = [];
  final List<AvailabilitySlotModel> _availabilitySlots = [];
  bool _isSubmitting = false;

  bool get _isParcelTransport => _serviceCategory == ServiceCategory.transport;

  static const _categoryIcons = {
    ServiceCategory.transport: Icons.flight_takeoff_rounded,
    ServiceCategory.housing: Icons.home_rounded,
    ServiceCategory.translation: Icons.translate_rounded,
    ServiceCategory.administrativeHelp: Icons.description_rounded,
    ServiceCategory.groceries: Icons.shopping_basket_rounded,
    ServiceCategory.tutoring: Icons.school_rounded,
    ServiceCategory.cleaning: Icons.cleaning_services_rounded,
    ServiceCategory.repair: Icons.build_rounded,
    ServiceCategory.other: Icons.more_horiz_rounded,
  };

  static const _categoryLabels = {
    ServiceCategory.transport: 'Transport de colis ✈️📦',
    ServiceCategory.housing: 'Logement & Hébergement',
    ServiceCategory.translation: 'Traduction & Interprétariat',
    ServiceCategory.administrativeHelp: 'Démarches & Aide administrative',
    ServiceCategory.groceries: 'Courses & Achats',
    ServiceCategory.tutoring: 'Soutien scolaire & Cours',
    ServiceCategory.cleaning: 'Ménage & Entretien',
    ServiceCategory.repair: 'Réparation & Bricolage',
    ServiceCategory.other: 'Autre prestation',
  };

  @override
  void initState() {
    super.initState();
    _departureDate = DateTime.now().add(const Duration(days: 7));
    _arrivalDate = DateTime.now().add(const Duration(days: 8));
    _pickupDeadline = DateTime.now().add(const Duration(days: 6));
    _updateDefaultTitle();
  }

  void _updateDefaultTitle() {
    if (_isParcelTransport && _titleController.text.isEmpty) {
      final dep = _departureCityController.text.isNotEmpty
          ? _departureCityController.text
          : _departureCountryController.text;
      final arr = _arrivalCityController.text.isNotEmpty
          ? _arrivalCityController.text
          : _arrivalCountryController.text;
      _titleController.text = 'Voyage $dep ➔ $arr - ${_capacityController.text} kg disponibles';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _departureCountryController.dispose();
    _departureCityController.dispose();
    _arrivalCountryController.dispose();
    _arrivalCityController.dispose();
    _capacityController.dispose();
    _pricePerKgController.dispose();
    _transportModeController.dispose();
    _flightNumberController.dispose();
    _prohibitedItemsController.dispose();
    _meetingPointsController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? get _validationHint {
    switch (_step) {
      case 0:
        if (_isParcelTransport) {
          if (_departureCountryController.text.trim().isEmpty) return 'Précisez le pays de départ';
          if (_arrivalCountryController.text.trim().isEmpty) return 'Précisez le pays de destination';
        }
        return null;
      case 1:
        if (_titleController.text.trim().length < 3) return 'Le titre doit comporter au moins 3 caractères';
        if (_descriptionController.text.trim().length < 5) return 'La description doit comporter au moins 5 caractères';
        if (_isParcelTransport && _departureDate == null) return 'Veuillez sélectionner la date de départ';
        return null;
      case 2:
        if (_isParcelTransport) {
          final kg = double.tryParse(_capacityController.text.trim()) ?? 0;
          final price = double.tryParse(_pricePerKgController.text.trim()) ?? 0;
          if (kg <= 0) return 'Indiquez un nombre de kilos supérieur à 0';
          if (price <= 0) return 'Indiquez un tarif au kilo supérieur à 0';
        } else {
          if (_paymentMode == 1 && (double.tryParse(_priceController.text.trim()) ?? 0) <= 0) {
            return 'Indiquez un montant valide';
          }
        }
        return null;
      default:
        return null;
    }
  }

  bool get _canContinue => _validationHint == null;

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

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final double? capacity = double.tryParse(_capacityController.text.trim());
      final double? priceKg = double.tryParse(_pricePerKgController.text.trim());
      final double? fixedPrice = double.tryParse(_priceController.text.trim());

      final dto = CreateListingDto(
        categoryId: _isParcelTransport ? 'transport-colis' : _categoryId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        contactInfo: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        paymentMode: _isParcelTransport ? 1 : _paymentMode,
        price: _isParcelTransport
            ? ((capacity ?? 0) * (priceKg ?? 0))
            : (_paymentMode == 1 ? fixedPrice : null),
        currency: _currency,
        imagePaths: _localPhotoPaths,
        availabilitySlots: _availabilitySlots,
        city: _isParcelTransport
            ? _departureCityController.text.trim()
            : (_cityController.text.trim().isEmpty ? null : _cityController.text.trim()),
        country: _isParcelTransport
            ? _departureCountryController.text.trim().toUpperCase()
            : (_countryController.text.trim().isEmpty ? null : _countryController.text.trim().toUpperCase()),
        serviceCategory: _serviceCategory,
        priceType: _isParcelTransport ? PriceType.fixed : _priceType,
        serviceScope: _serviceScope,
        allowedDepartments: _serviceScope == ServiceScope.departmentList
            ? _selectedDepartments
            : null,
        isStandardService: true,
        // Travel specific fields
        departureCountryCode: _isParcelTransport ? _departureCountryController.text.trim().toUpperCase() : null,
        departureCity: _isParcelTransport ? _departureCityController.text.trim() : null,
        arrivalCountryCode: _isParcelTransport ? _arrivalCountryController.text.trim().toUpperCase() : null,
        arrivalCity: _isParcelTransport ? _arrivalCityController.text.trim() : null,
        departureDate: _isParcelTransport ? _departureDate : null,
        arrivalDate: _isParcelTransport ? _arrivalDate : null,
        pickupDeadline: _isParcelTransport ? _pickupDeadline : null,
        capacityKg: _isParcelTransport ? capacity : null,
        remainingKg: _isParcelTransport ? capacity : null,
        pricePerKg: _isParcelTransport ? priceKg : null,
        transportMode: _isParcelTransport ? _transportModeController.text.trim() : null,
        prohibitedItemsDescription: _isParcelTransport ? _prohibitedItemsController.text.trim() : null,
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
              : (_isParcelTransport ? 'Trajet de transport de colis publié !' : 'Annonce publiée avec succès')),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _goBack,
          ),
          title: Text(
            widget.editListingId != null ? 'Modifier' : 'Proposer un service / trajet',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_step + 1}/$_stepCount',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Category(isDark),
                  _buildStep2Details(isDark),
                  _buildStep3PricingAndCapacity(isDark),
                  _buildStep4Review(isDark),
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
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_stepCount, (i) {
              final active = i <= _step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < _stepCount - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _stepTitles[_step],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final hint = _validationHint;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hint != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 15, color: Colors.amber[800]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hint,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                if (_step > 0) ...[
                  OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Précédent'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canContinue && !_isSubmitting ? _goNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _step == _stepCount - 1 ? 'Confirmer et publier' : 'Continuer',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Catégorie & Type (Affichage de la Catégorie EN PREMIER) ──

  Widget _buildStep1Category(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre catégorie',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sélectionnez la catégorie du service ou transport que vous proposez.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Grid of Categories
          ...ServiceCategory.values.map((cat) {
            final isSelected = _serviceCategory == cat;
            final isTransport = cat == ServiceCategory.transport;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _serviceCategory = cat;
                    _categoryId = isTransport ? 'transport-colis' : cat.name;
                    _updateDefaultTitle();
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : Colors.grey[200]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isSelected ? AppColors.primary : Colors.grey[400]!).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _categoryIcons[cat] ?? Icons.category_rounded,
                          color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _categoryLabels[cat] ?? cat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          // If Transport de colis is selected -> Corridor fields unlocked directly
          if (_isParcelTransport) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4338CA).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF4338CA), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Corridor de transport',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Pays départ', isDark),
                            TextField(
                              controller: _departureCountryController,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (_) {
                                _updateDefaultTitle();
                                setState(() {});
                              },
                              decoration: _inputDeco(isDark, 'TG, RU...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Ville départ', isDark),
                            TextField(
                              controller: _departureCityController,
                              onChanged: (_) {
                                _updateDefaultTitle();
                                setState(() {});
                              },
                              decoration: _inputDeco(isDark, 'Lomé, Moscou...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Pays arrivée', isDark),
                            TextField(
                              controller: _arrivalCountryController,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (_) {
                                _updateDefaultTitle();
                                setState(() {});
                              },
                              decoration: _inputDeco(isDark, 'RU, TG...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Ville arrivée', isDark),
                            TextField(
                              controller: _arrivalCityController,
                              onChanged: (_) {
                                _updateDefaultTitle();
                                setState(() {});
                              },
                              decoration: _inputDeco(isDark, 'Moscou, Lomé...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ('TG', 'Lomé', 'RU', 'Moscou', '🇹🇬 Lomé ➔ 🇷🇺 Moscou'),
                      ('RU', 'Moscou', 'TG', 'Lomé', '🇷🇺 Moscou ➔ 🇹🇬 Lomé'),
                      ('TG', 'Lomé', 'FR', 'Paris', '🇹🇬 Lomé ➔ 🇫🇷 Paris'),
                      ('CI', 'Abidjan', 'RU', 'Moscou', '🇨🇮 Abidjan ➔ 🇷🇺 Moscou'),
                    ].map((c) {
                      return ActionChip(
                        label: Text(c.$5, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _departureCountryController.text = c.$1;
                            _departureCityController.text = c.$2;
                            _arrivalCountryController.text = c.$3;
                            _arrivalCityController.text = c.$4;
                            _updateDefaultTitle();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 2: Détails du voyage ou de la prestation ──

  Widget _buildStep2Details(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isParcelTransport ? 'Détails du voyage' : 'Informations du service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          if (_isParcelTransport) ...[
            // Travel dates
            _label('Date estimée de départ', isDark),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _departureDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _departureDate = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: _boxDeco(isDark),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _departureDate != null
                          ? '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'
                          : 'Choisir la date',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label('Date limite de dépôt du colis', isDark),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _pickupDeadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: _departureDate ?? DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _pickupDeadline = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: _boxDeco(isDark),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _pickupDeadline != null
                          ? '${_pickupDeadline!.day}/${_pickupDeadline!.month}/${_pickupDeadline!.year}'
                          : 'Date limite',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Mode de transport', isDark),
                      TextField(
                        controller: _transportModeController,
                        decoration: _inputDeco(isDark, 'Ex: Avion, Train...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('N° de vol / transport', isDark),
                      TextField(
                        controller: _flightNumberController,
                        decoration: _inputDeco(isDark, 'Ex: AF123 (optionnel)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label('Points de rendez-vous préférés', isDark),
            TextField(
              controller: _meetingPointsController,
              decoration: _inputDeco(isDark, 'Ex: Aéroport de Lomé, quartier Tokoin...'),
            ),
            const SizedBox(height: 12),
            _label('Marchandises refusées / conditions', isDark),
            TextField(
              controller: _prohibitedItemsController,
              decoration: _inputDeco(isDark, 'Ex: Pas de liquides, pas de médicaments non prescrits...'),
            ),
            const SizedBox(height: 12),
          ] else ...[
            _label('Ville', isDark),
            TextField(
              controller: _cityController,
              decoration: _inputDeco(isDark, 'Ex: Lomé, Paris, Moscou...'),
            ),
            const SizedBox(height: 12),
            _label('Pays', isDark),
            TextField(
              controller: _countryController,
              decoration: _inputDeco(isDark, 'Ex: TG, RU, CI, FR...'),
            ),
            const SizedBox(height: 12),
            _label('Contact (téléphone ou email)', isDark),
            TextField(
              controller: _contactController,
              decoration: _inputDeco(isDark, 'Ex: +228 90 00 00 00 ou contact@mail.com'),
            ),
            const SizedBox(height: 12),
          ],
          _label('Titre', isDark),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: _inputDeco(isDark, 'Titre court et clair'),
          ),
          const SizedBox(height: 12),
          _label('Description', isDark),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: _inputDeco(isDark, 'Expliquez votre proposition, les horaires, les conditions...'),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Tarif, Capacité & Photos (Photos Optionnelles) ──

  Widget _buildStep3PricingAndCapacity(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isParcelTransport ? 'Capacité et tarif au kilo' : 'Tarification et disponibilité',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          if (_isParcelTransport) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Kilos disponibles (kg)', isDark),
                      TextField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDeco(isDark, 'Ex: 20'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tarif par kilo', isDark),
                      TextField(
                        controller: _pricePerKgController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDeco(isDark, 'Ex: 1000'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label('Devise', isDark),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: _inputDeco(isDark, ''),
              items: const ['XOF', 'RUB', 'EUR', 'USD']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _currency = v);
              },
            ),
            const SizedBox(height: 16),
            // Potential total earnings calculation
            Builder(builder: (context) {
              final kg = double.tryParse(_capacityController.text.trim()) ?? 0;
              final p = double.tryParse(_pricePerKgController.text.trim()) ?? 0;
              final total = (kg * p).toStringAsFixed(0);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gain potentiel estimé : $total $_currency ($kg kg × $p $_currency/kg)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            // Info: photos are not required for parcel transport
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Les photos sont optionnelles pour un transport de colis. Vous pouvez en ajouter une si vous le souhaitez.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _label('Mode de paiement', isDark),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Prix fixe'),
                    selected: _paymentMode == 1,
                    onSelected: (_) => setState(() => _paymentMode = 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Négociable'),
                    selected: _paymentMode == 2,
                    onSelected: (_) => setState(() => _paymentMode = 2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Gratuit'),
                    selected: _paymentMode == 0,
                    onSelected: (_) => setState(() => _paymentMode = 0),
                  ),
                ),
              ],
            ),
            if (_paymentMode == 1) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDeco(isDark, 'Montant'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: _inputDeco(isDark, ''),
                      items: const ['XOF', 'EUR', 'USD', 'RUB']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _currency = v);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 20),
          _label('Photos (optionnelles)', isDark),
          PhotoPickerGrid(
            localPaths: _localPhotoPaths,
            onAdd: (path) => setState(() => _localPhotoPaths.add(path)),
            onRemove: (path) => setState(() => _localPhotoPaths.remove(path)),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Récapitulatif ──

  Widget _buildStep4Review(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérifiez vos informations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _categoryIcons[_serviceCategory] ?? Icons.category_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categoryLabels[_serviceCategory] ?? _serviceCategory.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              _titleController.text,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_isParcelTransport) ...[
                    _reviewRow('Corridor', '${_departureCountryController.text} (${_departureCityController.text}) ➔ ${_arrivalCountryController.text} (${_arrivalCityController.text})'),
                    if (_departureDate != null)
                      _reviewRow('Départ', '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'),
                    if (_pickupDeadline != null)
                      _reviewRow('Dépôt colis max', '${_pickupDeadline!.day}/${_pickupDeadline!.month}/${_pickupDeadline!.year}'),
                    _reviewRow('Capacité', '${_capacityController.text} kg'),
                    _reviewRow('Tarif', '${_pricePerKgController.text} $_currency/kg'),
                    if (_transportModeController.text.isNotEmpty)
                      _reviewRow('Transport', _transportModeController.text),
                  ] else ...[
                    if (_cityController.text.isNotEmpty)
                      _reviewRow('Localisation', '${_cityController.text}, ${_countryController.text}'),
                    _reviewRow('Tarif', _paymentMode == 1 ? '${_priceController.text} $_currency' : (_paymentMode == 2 ? 'Négociable' : 'Gratuit')),
                  ],
                  const SizedBox(height: 8),
                  _reviewRow('Description', _descriptionController.text),
                  if (_localPhotoPaths.isNotEmpty)
                    _reviewRow('Photos', '${_localPhotoPaths.length} photo(s) ajoutée(s)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Les paiements sur les réservations de colis sont automatiquement protégés par séquestre et codes OTP de livraison.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white60 : Colors.grey[700],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  BoxDecoration _boxDeco(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? Colors.white12 : Colors.grey[200]!),
    );
  }
}
