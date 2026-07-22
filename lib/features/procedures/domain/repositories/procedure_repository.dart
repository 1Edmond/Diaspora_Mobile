import '../../../../core/network/paged_response.dart';
import '../entities/procedure.dart';
import '../entities/task.dart';

abstract class IProcedureRepository {
  Future<PagedResponse<Procedure>> getProcedures({
    int pageNumber = 1,
    int pageSize = 20,
    String? profileType,
    String? profileTypeId,
  });
  Future<List<Task>> getTasksForProcedure(String procedureId);
  Future<void> updateTaskStatus(String taskId, TaskStatus status);
  Future<void> recalculateProcedureProgress(String procedureId);
}