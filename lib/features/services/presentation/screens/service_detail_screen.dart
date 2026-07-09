import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/services_notifier.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({required this.serviceId, super.key});

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.read(servicesProvider.notifier).getDetail(widget.serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(child: Text('Erreur: ${snapshot.error}')),
          );
        }
        final s = snapshot.data;
        if (s == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Non trouvé')),
            body: const Center(child: Text('Service non trouvé')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(s.title)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(s.description),
                const SizedBox(height: 12),
                Text('Prix: ${s.price.toStringAsFixed(0)} ${s.currency}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Contacter'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
