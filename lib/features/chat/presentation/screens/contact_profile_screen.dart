import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/dio_client.dart';

class ContactProfileScreen extends StatefulWidget {
  final String contactId;
  final String? contactName;
  const ContactProfileScreen({super.key, required this.contactId, this.contactName});

  @override
  State<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends State<ContactProfileScreen> {
  Map<String, dynamic>? _contact;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    try {
      final client = getIt<DioClient>();
      final users = await client.get<List<dynamic>>('/users');
      final found = users.cast<Map<String, dynamic>>().where((u) => u['id'] == widget.contactId);
      setState(() {
        _contact = found.isNotEmpty ? found.first : null;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _contact?['name'] as String? ?? widget.contactName ?? 'Contact';
    final phone = _contact?['phone'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.getBackground(context),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.2),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                              ),
                              child: Center(
                                child: Text(initial, style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
                        const SizedBox(height: 4),
                        if (phone.isNotEmpty)
                          Text(phone, style: TextStyle(fontSize: 15, color: AppColors.getTextSecondary(context))),
                        const SizedBox(height: 4),
                        Text('Dernière vue il y a quelques minutes', style: TextStyle(fontSize: 13, color: AppColors.getTextSecondary(context))),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(icon: Icons.chat_bubble_rounded, label: 'Message', onTap: () => context.pop()),
                            const SizedBox(width: 16),
                            _ActionButton(icon: Icons.phone_rounded, label: 'Appel', onTap: () {}),
                            const SizedBox(width: 16),
                            _ActionButton(icon: Icons.videocam_rounded, label: 'Vidéo', onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildGlassCard(
                          context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fichiers et médias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.getTextMain(context))),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _MediaStat(icon: Icons.image_rounded, count: '12', label: 'Photos'),
                                  _MediaStat(icon: Icons.videocam_rounded, count: '3', label: 'Vidéos'),
                                  _MediaStat(icon: Icons.insert_drive_file_rounded, count: '8', label: 'Fichiers'),
                                  _MediaStat(icon: Icons.link_rounded, count: '5', label: 'Liens'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildGlassCard(
                          context,
                          child: ListTile(
                            leading: Icon(Icons.notifications_none_rounded, color: AppColors.getTextSecondary(context)),
                            title: Text('Ne plus déranger', style: TextStyle(color: AppColors.getTextMain(context))),
                            trailing: Switch(value: false, onChanged: (_) {}),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaStat extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _MediaStat({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.getTextSecondary(context)),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.getTextMain(context))),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context))),
      ],
    );
  }
}
