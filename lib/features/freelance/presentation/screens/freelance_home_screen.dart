import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/freelance_providers.dart';
import '../widgets/job_posting_card.dart';
import '../widgets/freelance_filter_sheet.dart';

class FreelanceHomeScreen extends ConsumerStatefulWidget {
  const FreelanceHomeScreen({super.key});

  @override
  ConsumerState<FreelanceHomeScreen> createState() =>
      _FreelanceHomeScreenState();
}

class _FreelanceHomeScreenState extends ConsumerState<FreelanceHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobSearchProvider.notifier).fetch(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Jobs',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: state.hasActiveFilters ? AppColors.primary : null,
            ),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(child: _buildList(state, isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (q) => ref
            .read(jobSearchProvider.notifier)
            .setFilters(searchQuery: q),
        decoration: InputDecoration(
          hintText: 'Rechercher une mission...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(jobSearchProvider.notifier)
                        .setFilters(searchQuery: '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList(JobSearchState state, bool isDark) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: FilledButton.icon(
          onPressed: () =>
              ref.read(jobSearchProvider.notifier).fetch(refresh: true),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline_rounded,
                  size: 72, color: isDark ? Colors.white24 : Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Aucune mission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final posting = state.items[index];
        return JobPostingCard(
          posting: posting,
          onTap: () => context.push('/freelance/${posting.id}'),
        );
      },
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FreelanceFilterSheet(),
    );
  }
}