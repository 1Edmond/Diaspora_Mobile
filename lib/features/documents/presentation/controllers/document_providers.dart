import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_category.dart';
import '../../domain/repositories/document_repository.dart';
import '../../data/repositories/document_repository_impl.dart';
import 'dart:io';

final documentRepositoryProvider = Provider<IDocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

// Providers for documents list by user
final documentsByUserProvider = FutureProvider.family<List<Document>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocuments(userId);
});

// Provider for documents filtered by category
final documentsByCategoryProvider = FutureProvider.family<
  List<Document>,
  ({String userId, DocumentCategory? category})
>((ref, params) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocuments(params.userId, category: params.category);
});

// Provider for a single document detail
final documentDetailProvider = FutureProvider.family<Document?, String>((
  ref,
  documentId,
) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentById(documentId);
});

// Provider for searching documents
final documentSearchProvider =
    FutureProvider.family<List<Document>, ({String userId, String query})>((
      ref,
      params,
    ) async {
      if (params.query.isEmpty) {
        return ref.watch(documentsByUserProvider(params.userId)).value ?? [];
      }

      final repository = ref.watch(documentRepositoryProvider);
      return repository.searchDocuments(params.userId, params.query);
    });

// Provider for expired documents
final expiredDocumentsProvider = FutureProvider.family<List<Document>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getExpiredDocuments(userId);
});

// StateNotifier for document upload
class DocumentUploadNotifier extends StateNotifier<AsyncValue<Document?>> {
  final IDocumentRepository repository;

  DocumentUploadNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> uploadDocument({
    required String userId,
    required String filePath,
    required String title,
    required DocumentCategory category,
    String? description,
    DateTime? expiresAt,
  }) async {
    state = const AsyncValue.loading();
    try {
      final document = await repository.uploadDocument(
        userId: userId,
        filePath: filePath,
        title: title,
        category: category,
        description: description,
        expiresAt: expiresAt,
      );
      state = AsyncValue.data(document);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final documentUploadProvider =
    StateNotifierProvider<DocumentUploadNotifier, AsyncValue<Document?>>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return DocumentUploadNotifier(repository);
    });

// StateNotifier for document deletion
class DocumentDeleteNotifier extends StateNotifier<AsyncValue<bool>> {
  final IDocumentRepository repository;

  DocumentDeleteNotifier(this.repository) : super(const AsyncValue.data(false));

  Future<void> deleteDocument(String documentId) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteDocument(documentId);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(false);
  }
}

final documentDeleteProvider =
    StateNotifierProvider<DocumentDeleteNotifier, AsyncValue<bool>>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return DocumentDeleteNotifier(repository);
    });

// StateNotifier for OCR text extraction
class TextExtractionNotifier extends StateNotifier<AsyncValue<String?>> {
  final IDocumentRepository repository;

  TextExtractionNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> extractText(String documentId) async {
    state = const AsyncValue.loading();
    try {
      final document = await repository.extractTextFromDocument(documentId);
      state = AsyncValue.data(document.extractedText);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final textExtractionProvider =
    StateNotifierProvider<TextExtractionNotifier, AsyncValue<String?>>((ref) {
      final repository = ref.watch(documentRepositoryProvider);
      return TextExtractionNotifier(repository);
    });

// Provider for file picker
final filePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

// State for selected file for upload
final selectedFileProvider = StateProvider<File?>((ref) {
  return null;
});
