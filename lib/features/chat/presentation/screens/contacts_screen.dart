import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/design_system.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final client = getIt<DioClient>();
      final res = await client.get<List<dynamic>>('/users');
      setState(() {
        _contacts = res.cast<Map<String, dynamic>>();
        _filtered = _contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _contacts;
      } else {
        _filtered = _contacts.where((c) {
          final name = (c['name'] as String? ?? '').toLowerCase();
          final phone = (c['phone'] as String? ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.getTextSecondary(context)),
                  filled: true,
                  fillColor: AppColors.getTextSecondary(context).withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(child: Text('Aucun contact', style: TextStyle(color: AppColors.getTextSecondary(context))))
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (c, i) => _ContactTile(contact: _filtered[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final Map<String, dynamic> contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final name = contact['name'] as String? ?? 'Inconnu';
    final phone = contact['phone'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(initial, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.getTextMain(context))),
      subtitle: phone.isNotEmpty ? Text(phone, style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context))) : null,
      trailing: IconButton(
        icon: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primary),
        onPressed: () => context.push('/chat/create', extra: contact),
      ),
    );
  }
}
