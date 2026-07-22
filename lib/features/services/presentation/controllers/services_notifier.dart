import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/service_model.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../../../shared/services/notification_service.dart';

final servicesProvider =
    StateNotifierProvider<ServicesNotifier, AsyncValue<List<ServiceModel>>>((
      ref,
    ) {
      IServiceRepository? repo;
      try {
        repo = GetIt.instance<IServiceRepository>();
      } catch (_) {
        repo = null;
      }
      return ServicesNotifier(repository: repo);
    });

class ServicesNotifier extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final IServiceRepository _repository;

  ServicesNotifier({IServiceRepository? repository})
    : _repository = repository ?? ServiceRepositoryImpl(),
      super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch({String? profileId}) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getServices(profileId ?? 'current_user');
      // Convert Entites to Models if needed, or just cast/map
      final models = list.map((s) => ServiceModel.fromEntity(s)).toList();
      state = AsyncValue.data(models);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // V2 Repo doesn't have getDetail, so we find it in state or fetch all
  Future<ServiceModel?> getDetail(String id) async {
    final currentList = state.value;
    if (currentList != null) {
      final matches = currentList.where((s) => s.id == id);
      if (matches.isNotEmpty) return matches.first;
    }
    // Fallback: fetch all and find
    await fetch();
    final matches = state.value?.where((s) => s.id == id);
    return (matches == null || matches.isEmpty) ? null : matches.first;
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final toCreate = ServiceModel(
      id: payload['id'] ?? 'svc_${DateTime.now().millisecondsSinceEpoch}',
      providerId: payload['providerId'] ?? 'unknown',
      title: payload['title'] ?? '',
      description: payload['description'] ?? '',
      price: (payload['price'] as num?)?.toDouble() ?? 0.0,
      currency: payload['currency'] ?? 'XOF',
      priceType: PriceType.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (payload['priceType'] ?? 'FIXED'),
        orElse: () => PriceType.FIXED,
      ),
      images: List<String>.from(payload['images'] ?? []),
      scope: ServiceScope.values.firstWhere(
        (e) =>
            e.toString().split('.').last == (payload['scope'] ?? 'CITY_ONLY'),
        orElse: () => ServiceScope.CITY_ONLY,
      ),
      allowedDepartments:
          payload['allowedDepartments'] != null
              ? List<String>.from(payload['allowedDepartments'])
              : null,
      rating: 0.0,
      reviewCount: 0,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );

    // Repository returns void now
    await _repository.createService(toCreate);

    // Optimistically add to state
    final current = state.value ?? [];
    state = AsyncValue.data([...current, toCreate]);
  }

  Future<void> approveService(
    String id, {
    required bool approved,
    ServiceScope scope = ServiceScope.CITY_ONLY,
    List<String>? allowedDepartments,
    String? reason,
  }) async {
    if (approved) {
      await _repository.approveService(id, scope, allowedDepartments);
    } else {
      await _repository.rejectService(id, reason ?? 'No reason provided');
    }

    // Refresh state
    await fetch();

    // Notification logic
    try {
      final notifier = GetIt.instance.get<NotificationService>();
      notifier.push({
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
        'title': approved ? 'Service approuvé' : 'Service rejeté',
        'body': approved ? 'Votre service est en ligne.' : 'Service refusé.',
      });
    } catch (_) {}
  }
}
