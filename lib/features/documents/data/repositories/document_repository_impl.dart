import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/paged_response.dart';
import '../../data/models/document_dto_model.dart';
import '../../domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements IDocumentRepository {
  final Dio _dio;

  DocumentRepositoryImpl({required Dio dio}) : _dio = dio;

  DocumentDtoModel _parseDocumentItem(Map<String, dynamic> json) {
    return DocumentDtoModel.fromJson(json);
  }

  @override
  Future<PagedResponse<DocumentDtoModel>> getDocuments({
    required int profileType,
    required String profileId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/documents/profile/$profileId',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'fetchDocuments failed: ${res.statusCode}',
      );
    }
    try {
      return PagedResponse.fromJson(res.data!, _parseDocumentItem);
    } catch (e, st) {
      if (kDebugMode) {
        print('Erreur de parsing PagedResponse<DocumentDtoModel>: $e');
        print(st);
      }
      rethrow;
    }
  }

  @override
  Future<DocumentDtoModel?> getDocumentById(String documentId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/documents/$documentId',
      );
      if (res.statusCode != 200 || res.data == null) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          message: 'fetchDocumentDetail failed: ${res.statusCode}',
        );
      }
      return DocumentDtoModel.fromJson(res.data!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DocumentDtoModel> uploadDocument({
    required String profileId,
    required String documentTypeId,
    required String filePath,
    String? fileName,
    DateTime? expiresAt,
    DateTime? issuedAt,
    String? issuedBy,
    bool forProcedure = false,
  }) async {
    final formData = FormData.fromMap({
      'ProfileId': profileId,
      'DocumentTypeId': documentTypeId,
      'File': await MultipartFile.fromFile(filePath, filename: fileName),
      if (expiresAt != null) 'ExpiresAt': expiresAt.toIso8601String(),
      if (issuedAt != null) 'IssuedAt': issuedAt.toIso8601String(),
      if (issuedBy != null) 'IssuedBy': issuedBy,
    });

    final res = await _dio.post<Map<String, dynamic>>(
      forProcedure ? '/documents/upload-for-proc' : '/documents/upload',
      data: formData,
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'uploadDocument failed: ${res.statusCode}',
      );
    }

    final data = res.data!;
    return DocumentDtoModel(
      id: (data['DocumentId'] ?? data['documentId']).toString(),
      profileId: profileId,
      documentTypeId: documentTypeId,
      fileName: (data['FileName'] ?? data['fileName']) as String?,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    final res = await _dio.delete<Map<String, dynamic>>(
      '/documents/$documentId',
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'deleteDocument failed: ${res.statusCode}',
      );
    }
  }

  @override
  Future<DocumentDtoModel> extractTextFromDocument(String documentId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/documents/$documentId/extract-text',
    );
    if (res.statusCode != 200 || res.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'extractText failed: ${res.statusCode}',
      );
    }
    return DocumentDtoModel.fromJson(res.data!);
  }

  @override
  Future<void> verifyDocument(String documentId) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/documents/$documentId/verify',
    );
    if (res.statusCode == null ||
        res.statusCode! < 200 ||
        res.statusCode! >= 300) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        message: 'verifyDocument failed: ${res.statusCode}',
      );
    }
  }
}
