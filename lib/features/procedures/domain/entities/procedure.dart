import 'task.dart';

enum ProcedureStatus { LOCKED, NOT_STARTED, IN_PROGRESS, COMPLETED }
enum ProcedureCategory { VISA, REGISTRATION, BANK, EDUCATION, OTHER }
enum ProfileType { INTERNAL, EXTERNAL }

class ProcedureTask {
  final String procedureId;
  final String taskId;
  final int order;
  final bool isOptional;
  // In a real app, we might need a reference to the actual Task object here or fetch it separate
  // For domain entity, holding the ID is often enough, or a Task object if loaded.
  // We'll hold the ID for relational link.

  ProcedureTask({
    required this.procedureId,
    required this.taskId,
    required this.order,
    this.isOptional = false,
  });
}

class Procedure {
  final String id;
  final String title;
  final String description;
  final ProfileType profileType;
  final ProcedureCategory category;
  final List<String> dependsOnProcedureIds;
  final List<ProcedureTask> tasks; 
  final ProcedureStatus status;
  final int userProgress; // 0-100

  Procedure({
    required this.id,
    required this.title,
    required this.description,
    required this.profileType,
    required this.category,
    this.dependsOnProcedureIds = const [],
    required this.tasks,
    required this.status,
    required this.userProgress,
  });
}
