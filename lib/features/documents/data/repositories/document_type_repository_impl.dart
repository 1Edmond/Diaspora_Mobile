import 'package:dio/dio.dart';
import '../../data/models/document_type_model.dart';
import '../../domain/repositories/document_type_repository.dart';

class DocumentTypeRepositoryImpl implements IDocumentTypeRepository {
  final Dio _dio;

  DocumentTypeRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DocumentTypeModel>> getDocumentTypes({String? profileTypeId}) async {
    final queryParams = <String, dynamic>{};
    if (profileTypeId != null && profileTypeId.isNotEmpty) {
      queryParams['profileTypeId'] = profileTypeId;
    }
    final res = await _dio.get<List<dynamic>>(
      '/document-types',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchDocumentTypes failed: ${res.statusCode}',
      );
    }
    return res.data!
        .map(
          (e) => DocumentTypeModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
