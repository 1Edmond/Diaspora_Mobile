import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_system.dart';
import '../controllers/chat_notifier.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollCtrl = ScrollController();
  bool _showScrollBtn = false;
  Message? _replyTarget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatNotifierProvider.notifier)
          .selectConversation(widget.conversationId);
    });
    _scrollCtrl.addListener(() {
      final atBottom = _scrollCtrl.position.pixels <= 100;
      if (atBottom == _showScrollBtn) {
        setState(() => _showScrollBtn = !atBottom);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool isGroup = false;
    chatState.whenData((state) {
      final convs =
          state.conversations.where((c) => c.id == widget.conversationId);
      if (convs.isNotEmpty) isGroup = convs.first.isGroup;
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E1621)
          : const Color(0xFFEFEFEF),
      body: Column(
        children: [
          _buildAppBar(chatState, isDark),
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
                            Icon(Icons.chat_outlined,
                                size: 48,
                                color: AppColors.getTextSecondary(context)),
                            const SizedBox(height: 12),
                            Text('Aucun message',
                                style: TextStyle(
                                    color:
                                        AppColors.getTextSecondary(context))),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state
                            .messages[state.messages.length - 1 - index];
                        final isLast = index == state.messages.length - 1;
                        final showDate = isLast ||
                            (index < state.messages.length - 1 &&
                                (msg.timestamp.day !=
                                        state.messages[state.messages.length -
                                                2 -
                                                index]
                                            .timestamp.day ||
                                    msg.timestamp.month !=
                                        state.messages[state.messages.length -
                                                2 -
                                                index]
                                            .timestamp.month ||
                                    msg.timestamp.year !=
                                        state.messages[state.messages.length -
                                                2 -
                                                index]
                                            .timestamp.year));
                        return Column(
                          children: [
                            if (showDate) _DateChip(date: msg.timestamp),
                            MessageBubble(
                              message: msg,
                              showSender: isGroup,
                              isGroupChat: isGroup,
                              repliedMessage: msg.replyToMessageId == null
                                  ? null
                                  : state.messages
                                      .where((m) => m.id == msg.replyToMessageId)
                                      .firstOrNull,
                              onSwipeReply: (m) => setState(() => _replyTarget = m),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Erreur: $e')),
                ),
                if (_showScrollBtn)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.getTextMain(context),
                        ),
                        onPressed: _scrollToBottom,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_replyTarget != null) _buildReplyBar(isDark),
          MessageInput(
            onSendMessage: _sendMessage,
            onSendVoiceMessage: (path, duration) {
              ref.read(chatNotifierProvider.notifier).sendMessage(
                    widget.conversationId,
                    '',
                    MessageType.AUDIO,
                    mediaUrl: path,
                    duration: duration,
                    replyToMessageId: _replyTarget?.id,
                  );
              setState(() => _replyTarget = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AsyncValue chatState, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          4, MediaQuery.of(context).padding.top + 4, 8, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17212B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: AppColors.getTextMain(context)),
            onPressed: () => context.pop(),
          ),
          chatState.maybeWhen(
            data: (state) {
              final convs = state.conversations
                  .where((c) => c.id == widget.conversationId);
              final conv = convs.isEmpty ? null : convs.first;
              final color = conv?.avatarColor ?? AppColors.primary;
              return GestureDetector(
                onTap: () => _showProfileInfo(context, conv),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.15),
                          ),
                          child: conv?.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    conv!.avatarUrl!,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildAvatarFallback(conv, color),
                                  ),
                                )
                              : _buildAvatarFallback(conv, color),
                        ),
                        if (conv?.isOnline == true)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF17212B)
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const Spacer(),
          chatState.maybeWhen(
            data: (state) {
              final convs = state.conversations
                  .where((c) => c.id == widget.conversationId);
              final conv = convs.isEmpty ? null : convs.first;
              return Column(
                children: [
                  Text(
                    conv?.title ?? 'Chat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.getTextMain(context),
                    ),
                  ),
                  Text(
                    conv?.isOnline == true
                        ? 'en ligne'
                        : 'dernière vue récemment',
                    style: TextStyle(
                      fontSize: 12,
                      color: conv?.isOnline == true
                          ? AppColors.accent
                          : AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              );
            },
            orElse: () => Text(
              'Chat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMain(context),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.search_rounded,
                color: AppColors.getTextSecondary(context)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(dynamic conv, Color color) {
    final initial =
        conv?.title != null && conv!.title.isNotEmpty
            ? conv.title[0].toUpperCase()
            : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  void _showProfileInfo(BuildContext context, dynamic conv) {
    if (conv == null) return;
    final conversation = conv as Conversation;
    if (conversation.isGroup) {
      _showGroupDetails(context, conversation);
    } else {
      final others =
          conversation.participants.where((String id) => id != 'user_1');
      final contactId =
          others.isNotEmpty ? others.first : conversation.participants.first;
      context.push('/contact-profile/$contactId', extra: conversation.title);
    }
  }

  void _showGroupDetails(BuildContext context, Conversation conv) {
    final members = conv.groupMembers ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              conv.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMain(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${conv.participants.length} membres',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun membre affiché',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (ctx, index) {
                        final member = members[index];
                        final name = member['name'] as String? ?? 'Membre';
                        final initial =
                            name.isNotEmpty ? name[0].toUpperCase() : '?';
                        final color = conv.avatarColor ?? AppColors.primary;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.15),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                              color: AppColors.getTextMain(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            member['role'] as String? ?? 'Membre',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar(bool isDark) {
    final target = _replyTarget!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isDark ? const Color(0xFF17212B) : Colors.white,
      child: Row(
        children: [
          Container(width: 3, height: 32, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.senderName ?? 'Réponse',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                Text(
                  target.type == MessageType.TEXT ? target.content : '📎 ${target.type.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: AppColors.getTextSecondary(context)),
            onPressed: () => setState(() => _replyTarget = null),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content, MessageType type,
      {String? mediaUrl, int? duration}) {
    ref.read(chatNotifierProvider.notifier).sendMessage(
        widget.conversationId, content, type,
        mediaUrl: mediaUrl, duration: duration, replyToMessageId: _replyTarget?.id);
    setState(() => _replyTarget = null);
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year
        ? "Aujourd'hui"
        : date.day == now.day - 1 &&
                date.month == now.month &&
                date.year == now.year
            ? 'Hier'
            : '${date.day}/${date.month}/${date.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
