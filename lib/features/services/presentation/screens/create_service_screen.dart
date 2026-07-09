import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/services_notifier.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier un service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final payload = {
                  'providerId': 'u_mock',
                  'title': _title.text.trim(),
                  'description': _desc.text.trim(),
                  'price': double.tryParse(_price.text.trim()) ?? 0.0,
                  'currency': 'EUR',
                  'priceType': 'FIXED',
                  'images': [],
                  'scope': 'CITY_ONLY',
                  'allowedDepartments': ['Moscou'],
                };

                await ref.read(servicesProvider.notifier).create(payload);
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Service soumis — en attente')),
                );
                context.pop();
              },
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}
