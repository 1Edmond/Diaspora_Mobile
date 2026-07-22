import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../../../data/mock/mock_services.dart';
import '../../../../core/config/app_config.dart';

class ServiceRepositoryImpl implements IServiceRepository {
  List<Service>? _localStore;

  List<Service> get _store {
    if (_localStore == null) {
      _localStore = List.from(mockServices);
    }
    return _localStore!;
  }

  @override
  Future<List<Service>> getServices(String profileId) async {
    if (AppConfig.useMockData) {
      return List.from(_store);
    }
    return [];
  }

  @override
  Future<void> createService(Service service) async {
    if (AppConfig.useMockData) {
      _store.add(service);
    }
  }

  @override
  Future<void> approveService(
    String serviceId,
    ServiceScope scope,
    List<String>? allowedDepartments,
  ) async {
    if (AppConfig.useMockData) {
      final index = _store.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final old = _store[index];
        _store[index] = Service(
          id: old.id,
          providerId: old.providerId,
          title: old.title,
          description: old.description,
          price: old.price,
          currency: old.currency,
          priceType: old.priceType,
          images: old.images,
          scope: scope,
          allowedDepartments: allowedDepartments,
          rating: old.rating,
          reviewCount: old.reviewCount,
          status: 'ACTIVE',
          createdAt: old.createdAt,
        );
      }
    }
  }

  @override
  Future<void> rejectService(String serviceId, String reason) async {
    if (AppConfig.useMockData) {
      final index = _store.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final old = _store[index];
        _store[index] = Service(
          id: old.id,
          providerId: old.providerId,
          title: old.title,
          description: old.description,
          price: old.price,
          currency: old.currency,
          priceType: old.priceType,
          images: old.images,
          scope: old.scope,
          allowedDepartments: old.allowedDepartments,
          rating: old.rating,
          reviewCount: old.reviewCount,
          status: 'REJECTED',
          createdAt: old.createdAt,
        );
      }
    }
  }
}
