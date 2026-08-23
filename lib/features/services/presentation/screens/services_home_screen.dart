import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/diaspora_app_bar.dart';
import '../../domain/entities/service.dart';
import '../controllers/services_notifier.dart';
import '../../data/models/service_model.dart';
import '../widgets/service_card.dart';

class ServicesHomeScreen extends ConsumerStatefulWidget {
  const ServicesHomeScreen({super.key});

  @override
  ConsumerState<ServicesHomeScreen> createState() => _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends ConsumerState<ServicesHomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ServiceCategory? _selectedCategory;
  String _sortBy = 'rating'; // rating, price_asc, price_desc, newest

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(servicesProvider.notifier).fetch());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceModel> _filterAndSort(List<ServiceModel> items) {
    var result = items.where((s) => s.status == 'ACTIVE').toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) =>
        s.title.toLowerCase().contains(q) ||
        s.description.toLowerCase().contains(q)
      ).toList();
    }

    if (_selectedCategory != null) {
      result = result.where((s) => s.category == _selectedCategory!).toList();
    }

    switch (_sortBy) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
      default:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);
    final categories = ServiceCategory.values;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                    child: DiasporaAppBar(
                      title: 'E-Services',
                      showBackButton: false,
                      trailing: IconButton(
                        icon: Icon(Icons.history_rounded, color: AppColors.getTextMain(context)),
                        onPressed: () => context.push('/services/reservations'),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un service...',
                          hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                          border: InputBorder.none,
                          icon: Icon(Icons.search_rounded, color: AppColors.getTextSecondary(context)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: AppColors.getTextSecondary(context)),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _FilterChip(
                          label: 'Tous',
                          selected: _selectedCategory == null,
                          onTap: () => setState(() => _selectedCategory = null),
                        ),
                        ...categories.map((c) => _FilterChip(
                          label: c.toString().split('.').last.replaceAll('_', ' '),
                          selected: _selectedCategory == c,
                          onTap: () => setState(() => _selectedCategory = c),
                        )),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          'Disponibles',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (v) => setState(() => _sortBy = v),
                          offset: const Offset(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Text(
                                'Trier',
                                style: TextStyle(
              fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.primary),
                            ],
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'rating', child: const Text('Meilleure note')),
                            PopupMenuItem(value: 'price_asc', child: const Text('Prix croissant')),
                            PopupMenuItem(value: 'price_desc', child: const Text('Prix décroissant')),
                            PopupMenuItem(value: 'newest', child: const Text('Plus récent')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                state.when(
                  data: (items) {
                    final filtered = _filterAndSort(items);
                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: AppColors.getTextSecondary(context)),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun service trouvé',
                                style: TextStyle(color: AppColors.getTextSecondary(context)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ServiceCard(
                              service: filtered[i],
                              onTap: () => context.push('/services/${filtered[i].id}'),
                            ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                  error: (e, s) => SliverFillRemaining(child: Center(child: Text('Erreur: $e'))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.getBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.getTextSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
