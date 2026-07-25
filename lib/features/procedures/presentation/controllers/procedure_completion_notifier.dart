import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import '../../../documents/data/models/document_dto_model.dart';
import '../../../documents/data/models/document_status.dart';
import '../../../documents/domain/repositories/document_repository.dart';
import '../../data/services/procedure_service.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import 'procedures_notifier.dart';

enum ProcedureDocMode { start, complete }

class DocumentSlot {
  PlatformFile? file;
  DateTime? expiresAt;
  DateTime? issuedAt;
  String? issuedBy;
  DocumentDtoModel? uploaded;

  DocumentSlot({
    this.file,
    this.expiresAt,
    this.issuedAt,
    this.issuedBy,
    this.uploaded,
  });

  bool get hasFile => file != null;
  bool get isUploaded => uploaded != null;
}

class ProcedureCompletionState {
  final List<String> docTypeIds;
  final List<DocumentSlot> slots;
  final bool isUploading;
  final bool isCompleting;
  final String? error;
  final bool isComplete;

  ProcedureCompletionState({
    required this.docTypeIds,
    List<DocumentSlot>? slots,
    this.isUploading = false,
    this.isCompleting = false,
    this.error,
    this.isComplete = false,
  }) : slots = slots ?? List.generate(docTypeIds.length, (_) => DocumentSlot());

  int get totalCount => docTypeIds.length;
  int get uploadedCount => slots.where((s) => s.isUploaded).length;
  bool get allFilesPicked =>
      slots.length == totalCount && slots.every((s) => s.hasFile);
  bool get allUploaded =>
      slots.length == totalCount && slots.every((s) => s.isUploaded);

  ProcedureCompletionState copyWith({
    List<DocumentSlot>? slots,
    bool? isUploading,
    bool? isCompleting,
    String? error,
    bool? isComplete,
  }) {
    return ProcedureCompletionState(
      docTypeIds: docTypeIds,
      slots: slots ?? this.slots,
      isUploading: isUploading ?? this.isUploading,
      isCompleting: isCompleting ?? this.isCompleting,
      error: error,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class ProcedureCompletionNotifier
    extends StateNotifier<ProcedureCompletionState> {
  final ProcedureService _procedureService;
  final IDocumentRepository _documentRepository;
  final Ref _ref;

  ProcedureCompletionNotifier({
    required List<String> docTypeIds,
    required Ref ref,
    ProcedureService? procedureService,
    IDocumentRepository? documentRepository,
  }) : _procedureService =
           procedureService ?? GetIt.instance<ProcedureService>(),
       _documentRepository =
           documentRepository ?? GetIt.instance<IDocumentRepository>(),
       _ref = ref,
       super(ProcedureCompletionState(docTypeIds: docTypeIds));

  void pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final slots = List<DocumentSlot>.generate(state.slots.length, (i) {
      if (i != index) return state.slots[i];
      return DocumentSlot(
        file: result.files.first,
        expiresAt: state.slots[i].expiresAt,
        issuedAt: state.slots[i].issuedAt,
        issuedBy: state.slots[i].issuedBy,
        uploaded: state.slots[i].uploaded,
      );
    });
    state = state.copyWith(slots: slots, error: null);
  }

  void removeFile(int index) {
    final slots = List<DocumentSlot>.generate(state.slots.length, (i) {
      if (i != index) return state.slots[i];
      return DocumentSlot();
    });
    state = state.copyWith(slots: slots);
  }

  void setExpiresAt(int index, DateTime? date) {
    final slots = List<DocumentSlot>.generate(state.slots.length, (i) {
      if (i != index) return state.slots[i];
      return DocumentSlot(
        file: state.slots[i].file,
        expiresAt: date,
        issuedAt: state.slots[i].issuedAt,
        issuedBy: state.slots[i].issuedBy,
        uploaded: state.slots[i].uploaded,
      );
    });
    state = state.copyWith(slots: slots);
  }

  void setIssuedAt(int index, DateTime? date) {
    final slots = List<DocumentSlot>.generate(state.slots.length, (i) {
      if (i != index) return state.slots[i];
      return DocumentSlot(
        file: state.slots[i].file,
        expiresAt: state.slots[i].expiresAt,
        issuedAt: date,
        issuedBy: state.slots[i].issuedBy,
        uploaded: state.slots[i].uploaded,
      );
    });
    state = state.copyWith(slots: slots);
  }

  void setIssuedBy(int index, String? value) {
    final slots = List<DocumentSlot>.generate(state.slots.length, (i) {
      if (i != index) return state.slots[i];
      return DocumentSlot(
        file: state.slots[i].file,
        expiresAt: state.slots[i].expiresAt,
        issuedAt: state.slots[i].issuedAt,
        issuedBy: value,
        uploaded: state.slots[i].uploaded,
      );
    });
    state = state.copyWith(slots: slots);
  }

  Future<List<String>?> checkExistingDocuments() async {
    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) return null;

    try {
      final profileType = profile!.isInternal ? 0 : 1;

      final paged = await _documentRepository.getDocuments(
        profileType: profileType,
        profileId: profileId,
        pageNumber: 1,
        pageSize: 100,
      );

      final activeDocs =
          paged.items.where((d) => d.status == DocumentStatus.active || d.status == DocumentStatus.pending).toList();

      final slots =
          List<DocumentSlot>.generate(state.slots.length, (i) => state.slots[i]);
      final foundIds = <String>[];

      for (int i = 0; i < state.docTypeIds.length; i++) {
        final match = activeDocs.where(
          (d) => d.documentTypeId == state.docTypeIds[i],
        ).firstOrNull;
        if (match != null) {
          slots[i] = DocumentSlot(
            expiresAt: match.expiresAt,
            issuedAt: match.issuedAt,
            issuedBy: match.issuedBy,
            uploaded: match,
          );
          foundIds.add(match.id);
        }
      }

      state = state.copyWith(slots: slots);
      if (foundIds.length == state.docTypeIds.length) return foundIds;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadAndComplete(
    String procedureId, {
    ProcedureDocMode mode = ProcedureDocMode.complete,
    String? userProcedureId,
  }) async {
    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) {
      state = state.copyWith(error: 'Aucun profil actif');
      return false;
    }

    state = state.copyWith(isUploading: true, error: null);

    final uploadedIds = <String>[];
    final slots = List<DocumentSlot>.generate(
      state.slots.length,
      (i) => state.slots[i],
    );

    for (int i = 0; i < state.docTypeIds.length; i++) {
      if (slots[i].isUploaded) {
        uploadedIds.add(slots[i].uploaded!.id);
        continue;
      }

      final file = slots[i].file;
      if (file == null) continue;

      try {
        final doc = await _documentRepository.uploadDocument(
          profileId: profileId,
          documentTypeId: state.docTypeIds[i],
          filePath: file.path ?? file.name,
          fileName: file.name,
          expiresAt: slots[i].expiresAt,
          issuedAt: slots[i].issuedAt,
          issuedBy: slots[i].issuedBy,
          forProcedure: true,
        );
        slots[i] = DocumentSlot(
          file: file,
          expiresAt: slots[i].expiresAt,
          issuedAt: slots[i].issuedAt,
          issuedBy: slots[i].issuedBy,
          uploaded: doc,
        );
        uploadedIds.add(doc.id);
        state = state.copyWith(slots: List.from(slots));
      } catch (e) {
        state = state.copyWith(
          isUploading: false,
          error: 'Erreur upload document ${i + 1} : $e',
        );
        return false;
      }
    }

    state = state.copyWith(isUploading: false, isCompleting: true);

    try {
      if (mode == ProcedureDocMode.start) {
        final newUserProcedureId = await _procedureService.startProcedure(
          procedureId: procedureId,
          profileId: profileId,
        );
        final provider = _ref.read(proceduresProvider.notifier);
        final mapping = Map<String, String>.from(provider.state.userProcedureIds)
          ..[procedureId] = newUserProcedureId;
        provider.state = provider.state.copyWith(userProcedureIds: mapping);
      } else {
        final upId = userProcedureId ?? _ref.read(proceduresProvider).userProcedureIds[procedureId];
        if (upId == null) {
          state = state.copyWith(
            isCompleting: false,
            error: 'Impossible de trouver la procédure utilisateur',
          );
          return false;
        }
        await _procedureService.completeProcedure(
          userProcedureId: upId,
          profileId: profileId,
          uploadedDocumentIds: uploadedIds,
        );
      }
      state = state.copyWith(isCompleting: false, isComplete: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        error: 'Erreur finalisation : $e',
      );
      return false;
    }
  }
}

final procedureCompletionProvider = StateNotifierProvider.family<
  ProcedureCompletionNotifier,
  ProcedureCompletionState,
  List<String>
>(
  (ref, docTypeIds) =>
      ProcedureCompletionNotifier(docTypeIds: docTypeIds, ref: ref),
);
