import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/document_dto_model.dart';
import '../../data/models/document_type_model.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/repositories/document_type_repository.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';

import 'package:get_it/get_it.dart';

final documentRepositoryProvider = Provider<IDocumentRepository>((ref) {
  return GetIt.instance<IDocumentRepository>();
});

final documentTypeRepositoryProvider = Provider<IDocumentTypeRepository>((ref) {
  return GetIt.instance<IDocumentTypeRepository>();
});

final documentTypesProvider = FutureProvider<List<DocumentTypeModel>>((
  ref,
) async {
  final repo = ref.watch(documentTypeRepositoryProvider);
  return repo.getDocumentTypes();
});

// ==================== Document sort ====================

enum DocumentSortField { date, name, status, size }

// ==================== Paginated documents list ====================

class DocumentsListState {
  final List<DocumentDtoModel> items;
  final bool isLoading;
  final bool hasNext;
  final int totalCount;
  final Object? error;
  final StackTrace? stackTrace;
  final String searchQuery;
  final String? selectedDocTypeId;
  final DocumentSortField sortField;
  final bool sortAscending;

  const DocumentsListState({
    this.items = const [],
    this.isLoading = false,
    this.hasNext = false,
    this.totalCount = 0,
    this.error,
    this.stackTrace,
    this.searchQuery = '',
    this.selectedDocTypeId,
    this.sortField = DocumentSortField.date,
    this.sortAscending = false,
  });

  List<DocumentDtoModel> get processedItems {
    var result = items.where((d) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final name = d.documentTypeName?.toLowerCase() ?? '';
        final fileName = d.fileName?.toLowerCase() ?? '';
        final code = d.documentTypeCode?.toLowerCase() ?? '';
        if (!name.contains(q) && !fileName.contains(q) && !code.contains(q)) {
          return false;
        }
      }
      if (selectedDocTypeId != null &&
          d.documentTypeId != selectedDocTypeId) {
        return false;
      }
      return true;
    }).toList();

    result.sort((a, b) {
      int cmp;
      switch (sortField) {
        case DocumentSortField.name:
          cmp = (a.documentTypeName ?? a.fileName ?? '')
              .compareTo(b.documentTypeName ?? b.fileName ?? '');
        case DocumentSortField.status:
          cmp = a.status.index.compareTo(b.status.index);
        case DocumentSortField.size:
          cmp = a.fileSize.compareTo(b.fileSize);
        case DocumentSortField.date:
          cmp = b.createdAt.compareTo(a.createdAt);
      }
      return sortAscending ? cmp : -cmp;
    });

    return result;
  }

  DocumentsListState copyWith({
    List<DocumentDtoModel>? items,
    bool? isLoading,
    bool? hasNext,
    int? totalCount,
    Object? error,
    StackTrace? stackTrace,
    String? searchQuery,
    String? selectedDocTypeId,
    DocumentSortField? sortField,
    bool? sortAscending,
  }) {
    return DocumentsListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
      stackTrace: stackTrace,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDocTypeId: selectedDocTypeId ?? this.selectedDocTypeId,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

final documentsListProvider =
    StateNotifierProvider<DocumentsListNotifier, DocumentsListState>((ref) {
      return DocumentsListNotifier(
        repository: ref.watch(documentRepositoryProvider),
        ref: ref,
      );
    });

class DocumentsListNotifier extends StateNotifier<DocumentsListState> {
  final IDocumentRepository _repository;
  final Ref _ref;
  int _currentPage = 1;
  static const _pageSize = 20;

  DocumentsListNotifier({
    required IDocumentRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(const DocumentsListState(isLoading: true));

  Future<void> fetch({int profileType = 0, String? profileId}) async {
    final pid = profileId ?? _resolveProfileId();
    if (pid == null || pid.isEmpty) {
      state = const DocumentsListState();
      return;
    }
    _currentPage = 1;
    state = state.copyWith(isLoading: true, error: null, stackTrace: null);
    try {
      final paged = await _repository.getDocuments(
        profileType: profileType,
        profileId: pid,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      state = DocumentsListState(
        items: paged.items,
        isLoading: false,
        hasNext: paged.hasNext,
        totalCount: paged.totalCount,
        searchQuery: state.searchQuery,
        selectedDocTypeId: state.selectedDocTypeId,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
      );
    } catch (e, st) {
      state = DocumentsListState(error: e, stackTrace: st);
    }
  }

  Future<void> loadNextPage({int profileType = 0, String? profileId}) async {
    final pid = profileId ?? _resolveProfileId();
    if (pid == null || pid.isEmpty) return;
    if (!state.hasNext || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      _currentPage++;
      final paged = await _repository.getDocuments(
        profileType: profileType,
        profileId: pid,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...paged.items],
        isLoading: false,
        hasNext: paged.hasNext,
        totalCount: paged.totalCount,
      );
    } catch (e, st) {
      _currentPage--;
      state = state.copyWith(isLoading: false, error: e, stackTrace: st);
    }
  }

  void refresh() {
    final pid = _resolveProfileId();
    if (pid != null && pid.isNotEmpty) {
      fetch(profileId: pid);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDocTypeFilter(String? docTypeId) {
    state = state.copyWith(
      selectedDocTypeId: state.selectedDocTypeId == docTypeId ? null : docTypeId,
    );
  }

  void setSortField(DocumentSortField field) {
    if (state.sortField == field) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortField: field, sortAscending: false);
    }
  }

  String? _resolveProfileId() {
    final activeProfile = _ref.read(activeProfileProvider);
    return activeProfile?.id;
  }
}

// ==================== Single document detail ====================

final documentDetailProvider = FutureProvider.family<DocumentDtoModel?, String>(
  (ref, documentId) async {
    final repository = ref.watch(documentRepositoryProvider);
    return repository.getDocumentById(documentId);
  },
);

// ==================== Upload ====================

class DocumentUploadNotifier
    extends StateNotifier<AsyncValue<DocumentDtoModel?>> {
  final IDocumentRepository repository;

  DocumentUploadNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> uploadDocument({
    required String profileId,
    required String documentTypeId,
    required String filePath,
    String? fileName,
    DateTime? expiresAt,
    DateTime? issuedAt,
    String? issuedBy,
    bool forProcedure = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final document = await repository.uploadDocument(
        profileId: profileId,
        documentTypeId: documentTypeId,
        filePath: filePath,
        fileName: fileName,
        expiresAt: expiresAt,
        issuedAt: issuedAt,
        issuedBy: issuedBy,
        forProcedure: forProcedure,
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

final documentUploadProvider = StateNotifierProvider<
  DocumentUploadNotifier,
  AsyncValue<DocumentDtoModel?>
>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentUploadNotifier(repository);
});

// ==================== Delete ====================

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

// ==================== OCR / Text extraction ====================

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
