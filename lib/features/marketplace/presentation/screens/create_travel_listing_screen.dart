import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/marketplace_dtos.dart';
import '../../domain/entities/listing.dart';
import '../controllers/marketplace_providers.dart';

class CreateTravelListingScreen extends ConsumerStatefulWidget {
  const CreateTravelListingScreen({super.key});

  @override
  ConsumerState<CreateTravelListingScreen> createState() =>
      _CreateTravelListingScreenState();
}

class _CreateTravelListingScreenState
    extends ConsumerState<CreateTravelListingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Corridor
  String _departureCountryCode = 'TG';
  String _departureCountryName = 'Togo';
  final TextEditingController _departureCityController =
      TextEditingController(text: 'Lomé');
  String _arrivalCountryCode = 'RU';
  String _arrivalCountryName = 'Russie';
  final TextEditingController _arrivalCityController =
      TextEditingController(text: 'Moscou');

  // Step 2: Dates
  DateTime _departureDate = DateTime.now().add(const Duration(days: 14));
  DateTime _arrivalDate = DateTime.now().add(const Duration(days: 15));
  DateTime _pickupDeadline = DateTime.now().add(const Duration(days: 13));

  // Step 3: Capacity & Pricing
  final TextEditingController _capacityKgController =
      TextEditingController(text: '20');
  final TextEditingController _pricePerKgController =
      TextEditingController(text: '5000');
  String _currency = 'XOF';

  // Step 4: Conditions & Handover
  String _transportMode = 'Avion';
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _meetingPointsController = TextEditingController();
  final TextEditingController _prohibitedItemsCustomController =
      TextEditingController();

  final List<String> _selectedProhibitedItems = [
    'Liquides > 100ml',
    'Aérosols & inflammables',
    'Denrées périssables fraîches',
    'Médicaments sans ordonnance',
  ];

  static const List<String> _availableProhibitedItems = [
    'Liquides > 100ml',
    'Aérosols & inflammables',
    'Denrées périssables fraîches',
    'Médicaments sans ordonnance',
    'Substances réglementées',
    'Alcool fort & Tabac en gros',
    'Objets de valeur non déclarés',
  ];

  static const List<Map<String, String>> _supportedCountries = [
    {'code': 'TG', 'name': 'Togo', 'flag': '🇹🇬', 'currency': 'XOF'},
    {'code': 'RU', 'name': 'Russie', 'flag': '🇷🇺', 'currency': 'RUB'},
    {'code': 'CI', 'name': 'Côte d\'Ivoire', 'flag': '🇨🇮', 'currency': 'XOF'},
    {'code': 'BJ', 'name': 'Bénin', 'flag': '🇧🇯', 'currency': 'XOF'},
    {'code': 'SN', 'name': 'Sénégal', 'flag': '🇸🇳', 'currency': 'XOF'},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷', 'currency': 'EUR'},
    {'code': 'CM', 'name': 'Cameroun', 'flag': '🇨🇲', 'currency': 'XAF'},
    {'code': 'BF', 'name': 'Burkina Faso', 'flag': '🇧🇫', 'currency': 'XOF'},
  ];

  bool _isSubmitting = false;
  String? _step1Error;
  String? _step2Error;
  String? _step3Error;

  @override
  void dispose() {
    _pageController.dispose();
    _departureCityController.dispose();
    _arrivalCityController.dispose();
    _capacityKgController.dispose();
    _pricePerKgController.dispose();
    _flightNumberController.dispose();
    _meetingPointsController.dispose();
    _prohibitedItemsCustomController.dispose();
    super.dispose();
  }

  void _swapCorridor() {
    setState(() {
      final tmpCode = _departureCountryCode;
      final tmpName = _departureCountryName;
      final tmpCity = _departureCityController.text;

      _departureCountryCode = _arrivalCountryCode;
      _departureCountryName = _arrivalCountryName;
      _departureCityController.text = _arrivalCityController.text;

      _arrivalCountryCode = tmpCode;
      _arrivalCountryName = tmpName;
      _arrivalCityController.text = tmpCity;
    });
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_departureCityController.text.trim().isEmpty) {
        setState(() => _step1Error = 'Veuillez renseigner la ville de départ');
        return false;
      }
      if (_arrivalCityController.text.trim().isEmpty) {
        setState(() => _step1Error = 'Veuillez renseigner la ville d\'arrivée');
        return false;
      }
      if (_departureCountryCode == _arrivalCountryCode &&
          _departureCityController.text.trim().toLowerCase() ==
              _arrivalCityController.text.trim().toLowerCase()) {
        setState(() => _step1Error = 'La ville de départ et d\'arrivée doivent être distinctes');
        return false;
      }
      setState(() => _step1Error = null);
      return true;
    }

    if (_currentStep == 1) {
      if (_arrivalDate.isBefore(_departureDate)) {
        setState(() => _step2Error = 'La date d\'arrivée doit être égale ou postérieure au départ');
        return false;
      }
      if (_pickupDeadline.isAfter(_departureDate)) {
        setState(() => _step2Error = 'La date limite de dépôt doit être antérieure au départ');
        return false;
      }
      setState(() => _step2Error = null);
      return true;
    }

    if (_currentStep == 2) {
      final capacity = double.tryParse(_capacityKgController.text.trim());
      if (capacity == null || capacity <= 0) {
        setState(() => _step3Error = 'Veuillez indiquer une capacité valide (> 0 kg)');
        return false;
      }
      final price = double.tryParse(_pricePerKgController.text.trim());
      if (price == null || price <= 0) {
        setState(() => _step3Error = 'Veuillez indiquer un tarif par kilo valide (> 0)');
        return false;
      }
      setState(() => _step3Error = null);
      return true;
    }

    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _calculatedTotalEarnings {
    final kg = double.tryParse(_capacityKgController.text.trim()) ?? 0.0;
    final price = double.tryParse(_pricePerKgController.text.trim()) ?? 0.0;
    return kg * price;
  }

  String _formatAmount(double amount) {
    final s = amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2);
    final parts = s.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    if (parts.length > 1) {
      return '$integerPart.${parts[1]}';
    }
    return integerPart;
  }

  Future<void> _submitTravelListing() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isSubmitting = true);

    try {
      final capacity = double.parse(_capacityKgController.text.trim());
      final pricePerKg = double.parse(_pricePerKgController.text.trim());

      final depFlag = Listing.countryCodeToEmoji(_departureCountryCode);
      final arrFlag = Listing.countryCodeToEmoji(_arrivalCountryCode);
      final title = 'Transport de colis : ${_departureCityController.text.trim()} $depFlag ➔ ${_arrivalCityController.text.trim()} $arrFlag';

      final prohibitedDesc = [
        ..._selectedProhibitedItems,
        if (_prohibitedItemsCustomController.text.trim().isNotEmpty)
          _prohibitedItemsCustomController.text.trim(),
      ].join(', ');

      final description = 'Trajet $_transportMode prévu le ${DateFormat('dd/MM/yyyy').format(_departureDate)}. '
          'Capacité disponible : $capacity kg à $pricePerKg $_currency/kg. '
          'Dépôt au plus tard le ${DateFormat('dd/MM/yyyy').format(_pickupDeadline)}. '
          'Lieu de remise : ${_meetingPointsController.text.trim().isEmpty ? "À convenir" : _meetingPointsController.text.trim()}. '
          'Objets interdits : $prohibitedDesc.';

      final dto = CreateListingDto(
        categoryId: 'travel-parcels',
        title: title,
        description: description,
        contactInfo: _meetingPointsController.text.trim(),
        paymentMode: 1, // Prix fixe
        price: pricePerKg,
        currency: _currency,
        imagePaths: const [],
        availabilitySlots: const [],
        city: _departureCityController.text.trim(),
        country: _departureCountryCode,
        isStandardService: false,
        departureCountryCode: _departureCountryCode,
        departureCity: _departureCityController.text.trim(),
        arrivalCountryCode: _arrivalCountryCode,
        arrivalCity: _arrivalCityController.text.trim(),
        departureDate: _departureDate,
        arrivalDate: _arrivalDate,
        pickupDeadline: _pickupDeadline,
        capacityKg: capacity,
        remainingKg: capacity,
        pricePerKg: pricePerKg,
        transportMode: _transportMode,
        prohibitedItemsDescription: prohibitedDesc,
      );

      final repo = ref.read(marketplaceRepositoryProvider);
      await repo.createListing(dto);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Votre trajet a été publié avec succès !')),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/marketplace');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la publication : $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publier un trajet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildProgressBar(context),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (idx) => setState(() => _currentStep = idx),
          children: [
            _buildStep1Corridor(context),
            _buildStep2Dates(context),
            _buildStep3CapacityAndPricing(context),
            _buildStep4Conditions(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stepLabels = ['Corridor', 'Dates', 'Capacité & Prix', 'Remise'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppColors.primary
                              : (isDark ? Colors.grey[800] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepLabels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.primary
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < _totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1Corridor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final depFlag = Listing.countryCodeToEmoji(_departureCountryCode);
    final arrFlag = Listing.countryCodeToEmoji(_arrivalCountryCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.flight_takeoff_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Corridor & Itinéraire',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'D\'où partez-vous et où allez-vous ?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Visual Preview Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(depFlag, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(
                        _departureCityController.text.isEmpty
                            ? 'Départ'
                            : _departureCityController.text,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _departureCountryName,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('swap_corridor_button'),
                  onPressed: _swapCorridor,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 28),
                  tooltip: 'Inverser l\'itinéraire',
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(arrFlag, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(
                        _arrivalCityController.text.isEmpty
                            ? 'Arrivée'
                            : _arrivalCityController.text,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _arrivalCountryName,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Departure Section
          const Text(
            'Lieu de départ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildCountryDropdown(
            key: const Key('departure_country_dropdown'),
            selectedCode: _departureCountryCode,
            onChanged: (code, name, currency) {
              setState(() {
                _departureCountryCode = code;
                _departureCountryName = name;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('departure_city_field'),
            controller: _departureCityController,
            decoration: InputDecoration(
              labelText: 'Ville de départ',
              hintText: 'Ex: Lomé',
              prefixIcon: const Icon(Icons.location_city_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Arrival Section
          const Text(
            'Lieu d\'arrivée',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildCountryDropdown(
            key: const Key('arrival_country_dropdown'),
            selectedCode: _arrivalCountryCode,
            onChanged: (code, name, currency) {
              setState(() {
                _arrivalCountryCode = code;
                _arrivalCountryName = name;
                _currency = currency;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('arrival_city_field'),
            controller: _arrivalCityController,
            decoration: InputDecoration(
              labelText: 'Ville d\'arrivée',
              hintText: 'Ex: Moscou',
              prefixIcon: const Icon(Icons.pin_drop_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => setState(() {}),
          ),

          if (_step1Error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _step1Error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountryDropdown({
    required Key key,
    required String selectedCode,
    required void Function(String code, String name, String currency) onChanged,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCode,
          isExpanded: true,
          items: _supportedCountries.map((c) {
            return DropdownMenuItem<String>(
              value: c['code'],
              child: Row(
                children: [
                  Text(c['flag'] ?? '🌍', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    '${c['name']} (${c['code']})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            final match = _supportedCountries.firstWhere((c) => c['code'] == val);
            onChanged(match['code']!, match['name']!, match['currency'] ?? 'XOF');
          },
        ),
      ),
    );
  }

  Widget _buildStep2Dates(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_available_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dates du voyage',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Planifiez votre calendrier de transport',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Departure Date Tile
          _buildDateSelectorTile(
            key: const Key('departure_date_tile'),
            title: 'Date de départ / vol',
            subtitle: 'Jour où vous prenez l\'avion / transport',
            date: _departureDate,
            icon: Icons.flight_takeoff_rounded,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _departureDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _departureDate = picked;
                  if (_arrivalDate.isBefore(_departureDate)) {
                    _arrivalDate = _departureDate;
                  }
                  if (_pickupDeadline.isAfter(_departureDate)) {
                    _pickupDeadline = _departureDate.subtract(const Duration(days: 1));
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Arrival Date Tile
          _buildDateSelectorTile(
            key: const Key('arrival_date_tile'),
            title: 'Date d\'arrivée estimée',
            subtitle: 'Arrivée dans la ville de destination',
            date: _arrivalDate,
            icon: Icons.flight_land_rounded,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _arrivalDate,
                firstDate: _departureDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _arrivalDate = picked);
              }
            },
          ),
          const SizedBox(height: 16),

          // Pickup Deadline Date Tile
          _buildDateSelectorTile(
            key: const Key('pickup_deadline_tile'),
            title: 'Date limite de dépôt de colis',
            subtitle: 'Date max à laquelle vous acceptez les colis',
            date: _pickupDeadline,
            icon: Icons.timer_outlined,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _pickupDeadline.isBefore(_departureDate)
                    ? _pickupDeadline
                    : _departureDate,
                firstDate: DateTime.now(),
                lastDate: _departureDate,
              );
              if (picked != null) {
                setState(() => _pickupDeadline = picked);
              }
            },
          ),

          if (_step2Error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _step2Error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelectorTile({
    required Key key,
    required String title,
    required String subtitle,
    required DateTime date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('dd/MM/yyyy').format(date);

    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3CapacityAndPricing(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalEarnings = _calculatedTotalEarnings;
    final totalEarningsStr = _formatAmount(totalEarnings);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.scale_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capacité & Tarifs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Définissez vos kilos et votre rémunération',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Capacity input
          TextFormField(
            key: const Key('capacity_kg_field'),
            controller: _capacityKgController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Kilos disponibles (kg)',
              hintText: 'Ex: 20',
              prefixIcon: const Icon(Icons.luggage_rounded),
              suffixText: 'kg',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Price per kg + Currency
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  key: const Key('price_per_kg_field'),
                  controller: _pricePerKgController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Tarif par kilo',
                    hintText: 'Ex: 5000',
                    prefixIcon: const Icon(Icons.payments_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currency,
                      isExpanded: true,
                      items: ['XOF', 'RUB', 'EUR', 'USD', 'XAF'].map((curr) {
                        return DropdownMenuItem<String>(
                          value: curr,
                          child: Text(curr, style: const TextStyle(fontWeight: FontWeight.w700)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _currency = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estimated Total Earnings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E3A2B), const Color(0xFF162E22)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.green, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Gain potentiel estimé',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalEarningsStr $_currency',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.green[300] : Colors.green[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Calculé sur la base de ${_capacityKgController.text.trim()} kg × ${_pricePerKgController.text.trim()} $_currency/kg si tous vos kilos sont réservés.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          if (_step3Error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _step3Error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4Conditions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conditions & Remise',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Précisez les modalités de transport et de collecte',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transport Mode Selector
          const Text(
            'Mode de transport',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            key: const Key('transport_mode_selector'),
            child: Wrap(
              spacing: 10,
              children: [
                _buildTransportChip('Avion', Icons.flight_rounded),
                _buildTransportChip('Train', Icons.train_rounded),
                _buildTransportChip('Voiture', Icons.directions_car_rounded),
                _buildTransportChip('Bateau', Icons.directions_boat_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Flight / Transport Reference (optional)
          TextFormField(
            controller: _flightNumberController,
            decoration: InputDecoration(
              labelText: 'N° de vol / Compagnie (optionnel)',
              hintText: 'Ex: Air France AF845',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),

          // Handover point
          const Text(
            'Point de rendez-vous pour la remise',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _meetingPointsController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Ex: Aéroport de Lomé Tokoin le 16/11 ou centre-ville...',
              prefixIcon: const Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),

          // Prohibited items checklist
          const Text(
            'Articles formellement refusés',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Conformément aux règles de sécurité aérienne et douanière',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableProhibitedItems.map((item) {
              final isSelected = _selectedProhibitedItems.contains(item);
              return FilterChip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: Colors.red.withValues(alpha: 0.15),
                checkmarkColor: Colors.red,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.red[700] : (isDark ? Colors.white70 : Colors.grey[800]),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProhibitedItems.add(item);
                    } else {
                      _selectedProhibitedItems.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('submit_travel_listing_button'),
              onPressed: _isSubmitting ? null : _submitTravelListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Publier mon trajet de transport',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportChip(String mode, IconData icon) {
    final isSelected = _transportMode == mode;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      label: Text(mode),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _transportMode = mode);
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    if (_currentStep == _totalSteps - 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Précédent'),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          ElevatedButton.icon(
            key: const Key('wizard_next_button'),
            onPressed: _nextStep,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
