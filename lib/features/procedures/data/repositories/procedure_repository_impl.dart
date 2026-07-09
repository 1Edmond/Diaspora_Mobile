import '../../domain/entities/procedure.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/procedure_repository.dart';
import '../../../../data/mock/mock_procedures.dart'; // We will use this source
import '../../../../core/config/app_config.dart';

class ProcedureRepositoryImpl implements IProcedureRepository {
  // Simulating in-memory DB for the mock session
  // In real app, this would be SQLite/Hive + API

  @override
  Future<List<Procedure>> getProcedures(String profileId) async {
    if (AppConfig.useMockData) {
      // Filter mock procedures by profile logic (omitted for MVP basics)
      return List<Procedure>.from(mockProcedures);
    }
    // TODO: Implement API call
    return [];
  }

  @override
  Future<List<Task>> getTasksForProcedure(String procedureId) async {
    if (AppConfig.useMockData) {
      final procedure = mockProcedures.firstWhere(
        (p) => p.id == procedureId,
        orElse: () => null,
      );
      if (procedure == null) return [];

      // Find tasks from mockTasks based on IDs in procedure
      final tasks = <Task>[];
      for (var procTask in procedure.tasks) {
        final task = mockTasks.firstWhere(
          (t) => t.id == procTask.taskId,
          orElse: () => null,
        );
        if (task != null) tasks.add(task);
      }
      return tasks;
    }
    return [];
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    if (AppConfig.useMockData) {
      // 1. Update the unique Task entity
      final taskIndex = mockTasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        // Create new copy with updated status (immutable style)
        final oldTask = mockTasks[taskIndex];
        mockTasks[taskIndex] = Task(
          id: oldTask.id,
          title: oldTask.title,
          description: oldTask.description,
          cost: oldTask.cost,
          estimatedDuration: oldTask.estimatedDuration,
          status: status,
          completedAt: status == TaskStatus.COMPLETED ? DateTime.now() : null,
          completedBy: null, // User ID
        );
      }

      // 2. "Task completed once = completed everywhere"
      // Recalculate progress for ALL procedures using this task
      for (var p in mockProcedures) {
        if (p.tasks.any((pt) => pt.taskId == taskId)) {
          await recalculateProcedureProgress(p.id);
        }
      }
    }
  }

  @override
  Future<void> recalculateProcedureProgress(String procedureId) async {
    if (AppConfig.useMockData) {
      final pIndex = mockProcedures.indexWhere((p) => p.id == procedureId);
      if (pIndex == -1) return;

      final procedure = mockProcedures[pIndex];
      int completed = 0;
      int total = 0;

      for (var procTask in procedure.tasks) {
        if (procTask.isOptional) continue;

        total++;
        final task = mockTasks.firstWhere(
          (t) => t.id == procTask.taskId,
          orElse: () => null,
        );
        if (task != null && task.status == TaskStatus.COMPLETED) {
          completed++;
        }
      }

      int progress = total == 0 ? 100 : ((completed / total) * 100).round();

      // Update procedure status if 100%
      ProcedureStatus newStatus = procedure.status;
      if (progress == 100)
        newStatus = ProcedureStatus.COMPLETED;
      else if (progress > 0)
        newStatus = ProcedureStatus.IN_PROGRESS;

      mockProcedures[pIndex] = Procedure(
        id: procedure.id,
        title: procedure.title,
        description: procedure.description,
        profileType: procedure.profileType,
        category: procedure.category,
        tasks: procedure.tasks,
        status: newStatus,
        userProgress: progress,
        dependsOnProcedureIds: procedure.dependsOnProcedureIds,
      );

      // 3. Check dependencies (if this completion unlocks others)
      // TODO: Implement dependency unlocking logic
    }
  }
}
