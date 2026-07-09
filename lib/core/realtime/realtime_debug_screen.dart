import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../core/constants/enums.dart'; // Added import
import 'mock_realtime_service.dart';

class RealtimeDebugScreen extends StatefulWidget {
  const RealtimeDebugScreen({super.key});

  @override
  State<RealtimeDebugScreen> createState() => _RealtimeDebugScreenState();
}

class _RealtimeDebugScreenState extends State<RealtimeDebugScreen> {
  final _conversationIdController = TextEditingController(text: 'conv_1');
  final _messageController = TextEditingController(text: 'Hello from debug');
  final _notificationTitle = TextEditingController(text: 'Test notif');
  final _notificationBody = TextEditingController(
    text: 'This is a mock notification',
  );
  final _postTitle = TextEditingController(text: 'New post title');
  final _postContent = TextEditingController(text: 'Post content');

  MockRealtimeService get _mock => GetIt.instance.get<MockRealtimeService>();

  @override
  void dispose() {
    _conversationIdController.dispose();
    _messageController.dispose();
    _notificationTitle.dispose();
    _notificationBody.dispose();
    _postTitle.dispose();
    _postContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Debug')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Emit Chat Message',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _conversationIdController,
              decoration: const InputDecoration(labelText: 'Conversation ID'),
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final msg = Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  conversationId: _conversationIdController.text.trim(),
                  senderId: 'debug_user',
                  senderName: 'Debugger', // senderName is nullable but allowed
                  content: _messageController.text.trim(),
                  timestamp: DateTime.now(),
                  type: MessageType.TEXT,
                  status: MessageStatus.SENT, // Replaced isRead with status
                );
                _mock.emitMessage(msg.conversationId, msg);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message emitted')),
                );
              },
              child: const Text('Emit Message'),
            ),

            const Divider(height: 32),

            const Text(
              'Emit Notification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _notificationTitle,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _notificationBody,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _mock.emitNotification({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': _notificationTitle.text,
                  'body': _notificationBody.text,
                  'target': 'user1',
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification emitted')),
                );
              },
              child: const Text('Emit Notification'),
            ),

            const Divider(height: 32),

            const Text(
              'Emit Community Post',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _postTitle,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _postContent,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _mock.emitCommunityEvent({
                  'event': 'post_created',
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'authorId': 'debug_user',
                  'authorName': 'Debugger',
                  'title': _postTitle.text,
                  'content': _postContent.text,
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post emitted')));
              },
              child: const Text('Emit Post'),
            ),

            const Divider(height: 32),

            const Text(
              'Emit Committee Proposal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                _mock.emitCommitteeEvent({
                  'event': 'proposal_created',
                  'committeeId': 'c_test',
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': 'Debug Proposal',
                  'description': 'Created from debug UI',
                  'proposerId': 'debug_user',
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proposal emitted')),
                );
              },
              child: const Text('Emit Proposal'),
            ),
          ],
        ),
      ),
    );
  }
}
