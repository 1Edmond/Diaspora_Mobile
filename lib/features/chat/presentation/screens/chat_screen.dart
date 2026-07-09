import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/chat_notifier.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../../../core/constants/enums.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollCtrl = ScrollController();
  bool _showScrollBtn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).selectConversation(widget.conversationId);
    });
    _scrollCtrl.addListener(() {
      final atBottom = _scrollCtrl.position.pixels <= 100;
      if (atBottom == _showScrollBtn) setState(() => _showScrollBtn = !atBottom);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          _buildAppBar(chatState),
          Expanded(
            child: Stack(
              children: [
                chatState.when(
                  data: (state) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined, size: 48, color: AppColors.getTextSecondary(context)),
                            const SizedBox(height: 12),
                            Text('Aucun message', style: TextStyle(color: AppColors.getTextSecondary(context))),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[state.messages.length - 1 - index];
                        final isLast = index == state.messages.length - 1;
                        final showDate = isLast ||
                            msg.timestamp.day != state.messages[state.messages.length - 2 - index].timestamp.day ||
                            msg.timestamp.month != state.messages[state.messages.length - 2 - index].timestamp.month ||
                            msg.timestamp.year != state.messages[state.messages.length - 2 - index].timestamp.year;
                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: _DateChip(date: msg.timestamp),
                              ),
                            MessageBubble(message: msg, showSender: false),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
                if (_showScrollBtn)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      heroTag: null,
                      backgroundColor: AppColors.getBackground(context),
                      onPressed: _scrollToBottom,
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          MessageInput(
            onSendMessage: _sendMessage,
            onSendVoiceMessage: (p, d) {},
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AsyncValue chatState) {
    return Container(
      padding: EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 4, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.getTextMain(context)),
              onPressed: () => context.pop(),
            ),
            chatState.maybeWhen(
              data: (state) {
                final convs = state.conversations.where((c) => c.id == widget.conversationId);
                final conv = convs.isEmpty ? null : convs.first;
                return Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Text(conv?.title[0].toUpperCase() ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showProfileInfo(context, conv),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conv?.title ?? 'Chat',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.getTextMain(context)),
                              ),
                              Text(
                                'vu il y a quelques minutes',
                                style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const Expanded(child: Text('Chat', style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            IconButton(icon: Icon(Icons.search_rounded, color: AppColors.getTextSecondary(context)), onPressed: () => _showSearch(context)),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: AppColors.getTextSecondary(context)),
              onSelected: (v) => _handleMenuAction(context, v),
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'profile', child: Text('Voir le profil')),
                const PopupMenuItem(value: 'media', child: Text('Fichiers et médias')),
                const PopupMenuItem(value: 'mute', child: Text('Ne plus déranger')),
                const PopupMenuItem(value: 'block', child: Text('Bloquer')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileInfo(BuildContext context, dynamic conv) {
    if (conv == null) return;
    final others = conv.participants.where((String id) => id != 'user_1');
    final contactId = others.isNotEmpty ? others.first : conv.participants.first;
    context.push('/contact-profile/$contactId', extra: conv.title);
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: _ChatSearchDelegate());
  }

  void _handleMenuAction(BuildContext context, String value) {
    if (value == 'profile') {
      final convs = ref.read(chatNotifierProvider).valueOrNull?.conversations.where((c) => c.id == widget.conversationId);
      _showProfileInfo(context, convs != null && convs.isNotEmpty ? convs.first : null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action: $value')));
    }
  }

  void _sendMessage(String content, MessageType type, {String? mediaUrl, int? duration}) {
    ref.read(chatNotifierProvider.notifier).sendMessage(widget.conversationId, content, type, mediaUrl: mediaUrl, duration: duration);
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = date.day == now.day && date.month == now.month && date.year == now.year
        ? "Aujourd'hui"
        : date.day == now.day - 1 && date.month == now.month && date.year == now.year
            ? 'Hier'
            : '${date.day}/${date.month}/${date.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.getTextSecondary(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context), fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ChatSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.close), onPressed: () => close(context, null))];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => const Center(child: Text('Recherche dans la conversation...'));
}
