import '../entities/task.dart';
import '../repositories/procedure_repository.dart';

class CompleteTaskUseCase {
  final IProcedureRepository repository;

  CompleteTaskUseCase(this.repository);

  /// Completes a task and updates all related procedures
  Future<void> execute(String taskId) async {
    // 1. Update the task status globally
    await repository.updateTaskStatus(taskId, TaskStatus.COMPLETED);

    // 2. Find all procedures that use this task
    // TODO: In a real DB, we'd query relation table.
    // For now, we assume the repository implementation handles finding related procedures
    // or we fetch all procedures and check properties.

    // For MVP/Mock implementation, the repository's 'updateTaskStatus'
    // should trigger the "Find all procedures" logic or we do it here if we had a
    // GetProceduresByTaskId method.

    // Let's assume the repository needs to explicitly recalculate for now to remain pure.
    // However, finding WHICH procedures to recalculate is the key V2 requirement.

    // Implementation Strategy:
    // The repository implementation will notify/update all procedures containing this taskId.
  }
}
