import '../entities/procedure.dart';
import '../entities/task.dart';

abstract class IProcedureRepository {
  Future<List<Procedure>> getProcedures(String profileId);
  Future<List<Task>> getTasksForProcedure(String procedureId);
  Future<void> updateTaskStatus(String taskId, TaskStatus status);
  Future<void> recalculateProcedureProgress(String procedureId);
}
