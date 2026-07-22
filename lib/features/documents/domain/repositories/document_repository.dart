import '../../../../core/network/paged_response.dart';
import '../../data/models/document_dto_model.dart';

abstract class IDocumentRepository {
  Future<PagedResponse<DocumentDtoModel>> getDocuments({
    required int profileType,
    required String profileId,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<DocumentDtoModel?> getDocumentById(String documentId);
  Future<DocumentDtoModel> uploadDocument({
    required String profileId,
    required String documentTypeId,
    required String filePath,
    String? fileName,
    DateTime? expiresAt,
    DateTime? issuedAt,
    String? issuedBy,
  });
  Future<void> deleteDocument(String documentId);
  Future<DocumentDtoModel> extractTextFromDocument(String documentId);
  Future<void> verifyDocument(String documentId);
}
