import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_notifier.dart';
import '../../../../core/theme/theme_provider.dart';
import '../widgets/theme_selector.dart';
import '../widgets/language_selector.dart';
import '../widgets/privacy_level_selector.dart';
import '../../domain/entities/settings_entity.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Général'),
              Tab(text: 'Confidentiel'),
              Tab(text: 'Notifications'),
              Tab(text: 'Sécurité'),
            ],
          ),
        ),
        body: settingsAsync.when(
          data:
              (settings) => TabBarView(
                children: [
                  _GeneralTab(settings, settingsNotifier),
                  _PrivacyTab(settings, settingsNotifier),
                  _NotificationsTab(settings, settingsNotifier),
                  _SecurityTab(settings, settingsNotifier),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}

class _GeneralTab extends ConsumerWidget {
  final SettingsEntity settings;
  final SettingsNotifier notifier;

  const _GeneralTab(this.settings, this.notifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ThemeSelector(
            selectedTheme: settings.theme,
            onThemeChanged: (theme) {
              notifier.updateTheme(theme);
              ref
                  .read(themeProvider.notifier)
                  .setThemeMode(
                    theme == 'dark'
                        ? ThemeMode.dark
                        : (theme == 'light'
                            ? ThemeMode.light
                            : ThemeMode.system),
                  );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Thème changé en $theme')));
            },
          ),
          LanguageSelector(
            selectedLanguage: settings.language,
            onLanguageChanged: (language) {
              notifier.updateLanguage(language);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Langue changée en $language')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  final SettingsEntity settings;
  final SettingsNotifier notifier;

  const _PrivacyTab(this.settings, this.notifier);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PrivacyLevelSelector(
            selectedLevel: settings.privacyLevel,
            onLevelChanged: (level) {
              notifier.updatePrivacyLevel(level);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Niveau de confidentialité mis à jour'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer le compte'),
                subtitle: const Text(
                  'Cette action est irréversible',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showDeleteAccountDialog(context, notifier),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    SettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer le compte'),
            content: const Text(
              'Êtes-vous sûr ? Cette action ne peut pas être annulée.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  notifier.deleteAccount();
                  context.pop();
                  context.pop(); // Go back to previous screen
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  final SettingsEntity settings;
  final SettingsNotifier notifier;

  const _NotificationsTab(this.settings, this.notifier);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Activer les notifications'),
          subtitle: const Text('Recevoir les mises à jour et les alertes'),
          value: settings.notificationsEnabled,
          onChanged: (_) {
            notifier.toggleNotifications();
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Types de notifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        CheckboxListTile(
          title: const Text('Notifications de chat'),
          subtitle: const Text('Nouveaux messages'),
          value: settings.notificationsEnabled,
          onChanged: (_) {},
        ),
        CheckboxListTile(
          title: const Text('Notifications de communauté'),
          subtitle: const Text('Nouveaux messages et likes'),
          value: settings.notificationsEnabled,
          onChanged: (_) {},
        ),
        CheckboxListTile(
          title: const Text('Notifications de services'),
          subtitle: const Text('Mises à jour de services'),
          value: settings.notificationsEnabled,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _SecurityTab extends StatelessWidget {
  final SettingsEntity settings;
  final SettingsNotifier notifier;

  const _SecurityTab(this.settings, this.notifier);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Authentification biométrique'),
          subtitle: const Text('Utiliser Face ID ou empreinte digitale'),
          value: settings.biometricAuthEnabled,
          onChanged: (_) {
            notifier.toggleBiometricAuth();
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Changer le mot de passe'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fonction à implémenter')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Historique de connexion'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fonction à implémenter')),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
