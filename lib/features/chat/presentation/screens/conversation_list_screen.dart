import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/chat_notifier.dart';
import '../widgets/story_avatar.dart';
import '../widgets/chat_list_item.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0;

  static const _filters = [
    'Tous',
    'Nouveau',
    'Famille',
    'Église',
    'Travail',
    'Communauté',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStories(context),
            _buildFilterTabs(),
            _buildSearch(context),
            Expanded(
              child: chatState.when(
                data: (state) {
                  final items = state.conversations.where((c) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        c.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                    final matchesFilter = _selectedFilter == 0 ||
                        (c.category?.toLowerCase() ==
                            _filters[_selectedFilter].toLowerCase());
                    return matchesSearch && matchesFilter;
                  }).toList();
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: AppColors.getTextSecondary(context)),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune conversation',
                            style: TextStyle(
                                color: AppColors.getTextSecondary(context)),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final conversation = items[index];
                      return ChatListItem(
                        conversation: conversation,
                        onTap: () =>
                            context.push('/chat/${conversation.id}'),
                      )
                          .animate()
                          .fadeIn(delay: (index * 40).ms)
                          .slideX(begin: 0.03);
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: $e'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(chatNotifierProvider.notifier)
                            .loadConversations(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/chat/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Chats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
              const SizedBox(width: 4),
              const Text('⭐', style: TextStyle(fontSize: 16)),
            ],
          ),
          const Spacer(),
          _buildHeaderButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            onTap: () => context.push('/chat/create'),
          ),
          const SizedBox(width: 4),
          _buildHeaderButton(
            context,
            icon: Icons.edit_square,
            onTap: () => context.push('/chat/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  Widget _buildStories(BuildContext context) {
    final stories = [
      {'name': 'Amadou', 'color': AppColors.primary, 'online': true},
      {'name': 'Fatou', 'color': AppColors.secondary, 'online': true},
      {'name': 'Kofi', 'color': AppColors.accent, 'online': false},
      {'name': 'Aïcha', 'color': Colors.orange, 'online': true},
      {'name': 'Yao', 'color': Colors.purple, 'online': false},
    ];

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          StoryAvatar(
            name: '+',
            isAddButton: true,
            size: 56,
            onTap: () => context.push('/story/add'),
          ),
          const SizedBox(width: 10),
          for (final story in stories)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: StoryAvatar(
                name: story['name'] as String,
                avatarColor: story['color'] as Color,
                isOnline: story['online'] as bool,
                size: 56,
                onTap: () => context.push('/story/view', extra: story['name']),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondary(context)
                        .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppColors.getTextSecondary(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextMain(context),
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
            prefixIcon: Icon(Icons.search_rounded,
                size: 20, color: AppColors.getTextSecondary(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
