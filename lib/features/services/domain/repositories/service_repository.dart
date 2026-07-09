import '../entities/service.dart';

abstract class IServiceRepository {
  Future<List<Service>> getServices(String profileId);
  Future<void> createService(Service service);
  Future<void> approveService(
    String serviceId,
    ServiceScope scope,
    List<String>? allowedDepartments,
  );
  Future<void> rejectService(String serviceId, String reason);
}
