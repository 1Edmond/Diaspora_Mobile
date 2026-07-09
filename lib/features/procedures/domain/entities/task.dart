import '../../../procedures/domain/entities/task_location.dart';
import '../../../procedures/domain/entities/required_document.dart';

enum TaskStatus { PENDING, COMPLETED }

class Task {
  final String id;
  final String title;
  final String description;
  final double cost; // Simplified for MVP, use Money class if available
  final List<dynamic> locations; // Placeholder for TaskLocation
  final List<dynamic> requiredDocuments; // Placeholder for RequiredDocument
  final Duration estimatedDuration;
  final TaskStatus status;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;
  final List<String> attachments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    this.locations = const [],
    this.requiredDocuments = const [],
    required this.estimatedDuration,
    required this.status,
    this.completedAt,
    this.completedBy,
    this.notes,
    this.attachments = const [],
  });
}
