import '../../domain/entities/document.dart';
import '../../domain/entities/document_category.dart';
import '../../domain/repositories/document_repository.dart';
import '../../../../core/network/dio_client.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  final DioClient _client;

  DocumentRepositoryImpl({DioClient? client}) : _client = client ?? DioClient();

  @override
  Future<List<Document>> getDocuments(
    String userId, {
    DocumentCategory? category,
  }) async {
    try {
      final queryParams = {'userId': userId};
      if (category != null) {
        queryParams['category'] = category.value;
      }

      final res = await _client.get<List<dynamic>>(
        '/documents',
        queryParameters: queryParams,
      );

      return res
          .map((e) => Document.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Document?> getDocumentById(String documentId) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/documents/$documentId',
      );
      return Document.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Document> uploadDocument({
    required String userId,
    required String filePath,
    required String title,
    required DocumentCategory category,
    String? description,
    DateTime? expiresAt,
  }) async {
    try {
      final payload = {
        'userId': userId,
        'title': title,
        'category': category.value,
        'description': description,
        'expiresAt': expiresAt?.toIso8601String(),
        'filePath': filePath,
      };

      final res = await _client.post<Map<String, dynamic>>(
        '/documents/upload',
        data: payload,
      );

      return Document.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _client.delete<Map<String, dynamic>>('/documents/$documentId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Document>> searchDocuments(String userId, String query) async {
    try {
      final res = await _client.get<List<dynamic>>(
        '/documents/search',
        queryParameters: {'userId': userId, 'query': query},
      );

      return res
          .map((e) => Document.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Document> extractTextFromDocument(String documentId) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/documents/$documentId/extract-text',
        data: {},
      );

      return Document.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyDocument(String documentId) async {
    try {
      await _client.put<Map<String, dynamic>>(
        '/documents/$documentId/verify',
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Document>> getExpiredDocuments(String userId) async {
    try {
      final res = await _client.get<List<dynamic>>(
        '/documents/expired',
        queryParameters: {'userId': userId},
      );

      return res
          .map((e) => Document.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
