import '../../data/models/document_type_model.dart';

abstract class IDocumentTypeRepository {
  Future<List<DocumentTypeModel>> getDocumentTypes();
}
