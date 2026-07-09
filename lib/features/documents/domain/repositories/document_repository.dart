import '../entities/document.dart';
import '../entities/document_category.dart';

abstract class IDocumentRepository {
  Future<List<Document>> getDocuments(
    String userId, {
    DocumentCategory? category,
  });
  Future<Document?> getDocumentById(String documentId);
  Future<Document> uploadDocument({
    required String userId,
    required String filePath,
    required String title,
    required DocumentCategory category,
    String? description,
    DateTime? expiresAt,
  });
  Future<void> deleteDocument(String documentId);
  Future<List<Document>> searchDocuments(String userId, String query);
  Future<Document> extractTextFromDocument(String documentId);
  Future<void> verifyDocument(String documentId);
  Future<List<Document>> getExpiredDocuments(String userId);
}
