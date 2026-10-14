import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../../domain/entities/enums.dart';
import '../controllers/marketplace_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _departureCountryController;
  late TextEditingController _arrivalCountryController;
  late double _maxDistanceKm;
  late bool _availableNow;
  late ListingSortBy _sortBy;
  String? _selectedCategoryId;

  bool get _isParcelTransport {
    if (_selectedCategoryId == null) return false;
    final cat = _selectedCategoryId!.toLowerCase();
    return cat == 'transport' ||
        cat == 'transport-colis' ||
        cat.contains('colis') ||
        cat.contains('transport');
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(marketplaceProvider);
    _minPriceController = TextEditingController(
      text: state.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: state.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _cityController = TextEditingController(text: state.city ?? '');
    _countryController = TextEditingController(text: state.country ?? '');
    _departureCountryController = TextEditingController(
      text: state.departureCountry ?? '',
    );
    _arrivalCountryController = TextEditingController(
      text: state.arrivalCountry ?? '',
    );
    _maxDistanceKm = state.maxDistanceKm ?? 50;
    _availableNow = state.availableNow;
    _sortBy = state.sortBy;
    _selectedCategoryId = state.selectedCategoryId;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _departureCountryController.dispose();
    _arrivalCountryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final notifier = ref.read(marketplaceProvider.notifier);
    notifier.setCategoryId(_selectedCategoryId);
    notifier.setPriceRange(
      _minPriceController.text.isNotEmpty
          ? double.tryParse(_minPriceController.text)
          : null,
      _maxPriceController.text.isNotEmpty
          ? double.tryParse(_maxPriceController.text)
          : null,
    );
    notifier.setLocation(
      _cityController.text.isEmpty ? null : _cityController.text,
      _countryController.text.isEmpty ? null : _countryController.text,
    );
    notifier.setCorridor(
      _departureCountryController.text.trim().isEmpty
          ? null
          : _departureCountryController.text.trim(),
      _arrivalCountryController.text.trim().isEmpty
          ? null
          : _arrivalCountryController.text.trim(),
    );
    notifier.setAvailableNow(_availableNow);
    notifier.setSortBy(_sortBy);
    Navigator.pop(context);
  }

  void _clearAll() {
    ref.read(marketplaceProvider.notifier).clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder:
          (context, scrollController) => Material(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildHandle()
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category at top as requested
                        _buildSectionTitle('Catégorie de service'),
                        const SizedBox(height: 12),
                        _buildCategorySelector(),
                        const SizedBox(height: 24),

                        // Corridor fields only appear if Transport de colis is selected
                        if (_isParcelTransport) ...[
                          _buildSectionTitle('Corridor de voyage (Colis) ✈️📦'),
                          const SizedBox(height: 12),
                          _buildCorridorFields(),
                          const SizedBox(height: 24),
                        ],

                        _buildSectionTitle('Tri'),
                        const SizedBox(height: 12),
                        _buildSortOptions(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Prix'),
                        const SizedBox(height: 12),
                        _buildPriceRange(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Localisation'),
                        const SizedBox(height: 12),
                        _buildLocationFields(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Distance max (km)'),
                        const SizedBox(height: 12),
                        _buildDistanceSlider(),
                        const SizedBox(height: 24),

                        _buildSectionTitle('Disponibilité'),
                        const SizedBox(height: 12),
                        _buildAvailabilityToggle(),
                        const SizedBox(height: 32),

                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filtres de recherche',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(marketplaceCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final hasTransport = categories.any(
          (c) =>
              c.id == 'transport-colis' ||
              c.name.toLowerCase().contains('colis') ||
              c.name.toLowerCase().contains('transport'),
        );

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Toutes'),
              selected: _selectedCategoryId == null,
              onSelected: (_) => setState(() => _selectedCategoryId = null),
            ),
            // Prominent Transport de colis chip
            ChoiceChip(
              label: const Text('Transport de colis ✈️📦'),
              selected: _isParcelTransport,
              onSelected:
                  (_) => setState(() {
                    _selectedCategoryId =
                        hasTransport
                            ? categories
                                .firstWhere(
                                  (c) =>
                                      c.id == 'transport-colis' ||
                                      c.name.toLowerCase().contains('colis') ||
                                      c.name.toLowerCase().contains(
                                        'transport',
                                      ),
                                )
                                .id
                            : 'transport-colis';
                  }),
            ),
            for (final category in categories)
              if (!category.name.toLowerCase().contains('colis') &&
                  !category.name.toLowerCase().contains('transport'))
                ChoiceChip(
                  label: Text('${category.name} (${category.count})'),
                  selected: _selectedCategoryId == category.id,
                  onSelected:
                      (_) => setState(() => _selectedCategoryId = category.id),
                ),
          ],
        );
      },
      loading:
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Toutes'),
                selected: _selectedCategoryId == null,
                onSelected: (_) => setState(() => _selectedCategoryId = null),
              ),
              ChoiceChip(
                label: const Text('Transport de colis ✈️📦'),
                selected: _selectedCategoryId == 'transport-colis',
                onSelected:
                    (_) =>
                        setState(() => _selectedCategoryId = 'transport-colis'),
              ),
            ],
          ),
      error:
          (_, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Toutes'),
                selected: _selectedCategoryId == null,
                onSelected: (_) => setState(() => _selectedCategoryId = null),
              ),
              ChoiceChip(
                label: const Text('Transport de colis ✈️📦'),
                selected: _selectedCategoryId == 'transport-colis',
                onSelected:
                    (_) =>
                        setState(() => _selectedCategoryId = 'transport-colis'),
              ),
            ],
          ),
    );
  }

  Widget _buildCorridorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('filter_departure_country_field'),
          controller: _departureCountryController,
          decoration: InputDecoration(
            labelText: 'Pays de départ (ex: Togo, TG)',
            hintText: 'Togo ou TG',
            prefixIcon: const Icon(Icons.flight_takeoff_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('filter_arrival_country_field'),
          controller: _arrivalCountryController,
          decoration: InputDecoration(
            labelText: 'Pays d\'arrivée (ex: Russie, RU)',
            hintText: 'Russie ou RU',
            prefixIcon: const Icon(Icons.flight_land_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              [
                ('TG', 'RU', '🇹🇬 Togo ➔ 🇷🇺 Russie'),
                ('RU', 'TG', '🇷🇺 Russie ➔ 🇹🇬 Togo'),
                ('TG', 'FR', '🇹🇬 Togo ➔ 🇫🇷 France'),
                ('CI', 'RU', '🇨🇮 Côte d\'Ivoire ➔ 🇷🇺 Russie'),
              ].map((c) {
                return ActionChip(
                  label: Text(c.$3, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _departureCountryController.text = c.$1;
                      _arrivalCountryController.text = c.$2;
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    const sortOptions = [
      (ListingSortBy.newest, 'Plus récent', Icons.access_time_rounded),
      (ListingSortBy.priceAsc, 'Prix croissant', Icons.arrow_upward_rounded),
      (
        ListingSortBy.priceDesc,
        'Prix décroissant',
        Icons.arrow_downward_rounded,
      ),
      (ListingSortBy.ratingDesc, 'Meilleures notes', Icons.star_rounded),
      (ListingSortBy.distance, 'Plus proche', Icons.near_me_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          sortOptions.map((option) {
            final isSelected = _sortBy == option.$1;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.$3, size: 16),
                  const SizedBox(width: 6),
                  Text(option.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _sortBy = option.$1),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : null,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPriceRange() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min',
              hintText: '0',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max',
              hintText: '100000',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'Ville',
            hintText: 'Lomé',
            prefixIcon: const Icon(Icons.location_city_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _countryController,
          decoration: InputDecoration(
            labelText: 'Pays',
            hintText: 'Togo',
            prefixIcon: const Icon(Icons.public_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_maxDistanceKm.round()} km',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        Slider(
          value: _maxDistanceKm,
          min: 1,
          max: 200,
          divisions: 199,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _maxDistanceKm = v),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return SwitchListTile(
      title: const Text('Disponible maintenant'),
      subtitle: const Text(
        'Afficher seulement les prestataires disponibles immédiatement',
      ),
      value: _availableNow,
      onChanged: (v) => setState(() => _availableNow = v),
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('Tout effacer'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red[300]!),
              foregroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Appliquer'),
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
      ],
    );
  }
}
