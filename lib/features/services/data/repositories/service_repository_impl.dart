import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../../../data/mock/mock_services.dart'; // Source
import '../../../../core/config/app_config.dart';

class ServiceRepositoryImpl implements IServiceRepository {
  @override
  Future<List<Service>> getServices(String profileId) async {
    if (AppConfig.useMockData) {
      // Filter logic would go here
      return List<Service>.from(mockServices);
    }
    return [];
  }

  @override
  Future<void> createService(Service service) async {
    if (AppConfig.useMockData) {
      mockServices.add(service);
    }
  }

  @override
  Future<void> approveService(
    String serviceId,
    ServiceScope scope,
    List<String>? allowedDepartments,
  ) async {
    if (AppConfig.useMockData) {
      final index = mockServices.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final old = mockServices[index];
        mockServices[index] = Service(
          id: old.id,
          providerId: old.providerId,
          title: old.title,
          description: old.description,
          price: old.price,
          currency: old.currency,
          priceType: old.priceType,
          images: old.images,
          scope: scope, // Updated scope
          allowedDepartments: allowedDepartments, // Updated departments
          rating: old.rating,
          reviewCount: old.reviewCount,
          status: 'ACTIVE', // Approved
          createdAt: old.createdAt,
        );
      }
    }
  }

  @override
  Future<void> rejectService(String serviceId, String reason) async {
    if (AppConfig.useMockData) {
      final index = mockServices.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final old = mockServices[index];
        mockServices[index] = Service(
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
