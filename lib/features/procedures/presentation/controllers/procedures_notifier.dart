import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/procedure_service.dart';
import '../../data/models/procedure_model.dart';
import '../../data/models/user_procedure_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';

class ProceduresState {
  final List<ProcedureModel> items;
  final bool isLoading;
  final bool hasNext;
  final int totalCount;
  final Object? error;
  final StackTrace? stackTrace;
  final Set<String> startedProcedureIds;
  final Set<String> completedProcedureIds;
  final Map<String, String> userProcedureIds;
  final Set<String>? _loadingProcedureIds;
  Set<String> get loadingProcedureIds => _loadingProcedureIds ?? const {};

  const ProceduresState({
    this.items = const [],
    this.isLoading = false,
    this.hasNext = false,
    this.totalCount = 0,
    this.error,
    this.stackTrace,
    this.startedProcedureIds = const {},
    this.completedProcedureIds = const {},
    this.userProcedureIds = const {},
    Set<String>? loadingProcedureIds,
  }) : _loadingProcedureIds = loadingProcedureIds;

  ProceduresState copyWith({
    List<ProcedureModel>? items,
    bool? isLoading,
    bool? hasNext,
    int? totalCount,
    Object? error,
    StackTrace? stackTrace,
    Set<String>? startedProcedureIds,
    Set<String>? completedProcedureIds,
    Map<String, String>? userProcedureIds,
    Set<String>? loadingProcedureIds,
  }) {
    return ProceduresState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasNext: hasNext ?? this.hasNext,
      totalCount: totalCount ?? this.totalCount,
      error: error,
      stackTrace: stackTrace,
      startedProcedureIds:
          startedProcedureIds ?? this.startedProcedureIds,
      completedProcedureIds:
          completedProcedureIds ?? this.completedProcedureIds,
      userProcedureIds:
          userProcedureIds ?? this.userProcedureIds,
      loadingProcedureIds:
          loadingProcedureIds ?? _loadingProcedureIds,
    );
  }
}

final proceduresProvider =
    StateNotifierProvider<ProceduresNotifier, ProceduresState>((ref) {
      final notifier = ProceduresNotifier(ref: ref);
      _scheduleProfileDependentFetch(ref, notifier);
      return notifier;
    });

void _scheduleProfileDependentFetch(
  Ref ref,
  ProceduresNotifier notifier,
) {
  void maybeFetch(AsyncValue<User?> authState) {
    final profiles = authState.valueOrNull?.profiles ?? [];
    if (profiles.isNotEmpty) {
      notifier.fetch(profileId: profiles.first.id);
    }
  }

  maybeFetch(ref.read(authNotifierProvider));
  ref.listen(authNotifierProvider, (_, next) => maybeFetch(next));
}

class ProceduresNotifier extends StateNotifier<ProceduresState> {
  final ProcedureService _service;
  final Ref _ref;
  int _currentPage = 1;
  static const _pageSize = 20;

  ProceduresNotifier({ProcedureService? service, required Ref ref})
    : _service =
          service ??
          (GetIt.instance.isRegistered<ProcedureService>()
              ? GetIt.instance<ProcedureService>()
              : ProcedureService()),
      _ref = ref,
      super(const ProceduresState(isLoading: true));

  String? get _profileTypeId {
    final activeProfile = _ref.read(activeProfileProvider);
    return activeProfile?.profileTypeId;
  }

  int get _profileType {
    final activeProfile = _ref.read(activeProfileProvider);
    return activeProfile?.isInternal == true ? 0 : 1;
  }

  Future<void> fetch({int profileType = 0, String? profileTypeId, String? profileId}) async {
    final id = profileTypeId ?? _profileTypeId;
    final pt = profileType >= 0 ? profileType : _profileType;
    _currentPage = 1;
    state = state.copyWith(isLoading: true, error: null, stackTrace: null);
    try {
      final pagedResponse = await _service.fetchProcedures(
        profileType: pt,
        profileTypeId: id,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      // Afficher tout de suite les procédures
      state = ProceduresState(
        items: pagedResponse.items,
        isLoading: false,
        hasNext: pagedResponse.hasNext,
        totalCount: pagedResponse.totalCount,
      );

      // Puis merger les statuts user-procedure de façon non-bloquante
      final pid = profileId ?? _ref.read(activeProfileProvider)?.id;
      if (pid != null && pid.isNotEmpty) {
        _mergeUserProcedures(pid);
      }
    } catch (e, st) {
      state = ProceduresState(error: e, stackTrace: st);
    }
  }

  Future<void> _mergeUserProcedures(String profileId) async {
    try {
      final userProcs = await _service.fetchUserProcedures(profileId: profileId);
      final started = <String>{};
      final completed = <String>{};
      final mapping = <String, String>{};
      for (final up in userProcs) {
        mapping[up.procedureId] = up.id;
        switch (up.status) {
          case UserProcedureStatus.inProgress:
            started.add(up.procedureId);
          case UserProcedureStatus.completed:
            completed.add(up.procedureId);
          default:
            break;
        }
      }
      if (mounted) {
        state = state.copyWith(
          startedProcedureIds: started,
          completedProcedureIds: completed,
          userProcedureIds: mapping,
        );
      }
    } catch (e, st) {
      debugPrint('_mergeUserProcedures failed: $e');
      debugPrint('$st');
    }
  }

  Future<void> loadNextPage({
    int profileType = 0,
    String? profileTypeId,
  }) async {
    final id = profileTypeId ?? _profileTypeId;
    final pt = profileType >= 0 ? profileType : _profileType;
    if (!state.hasNext || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      _currentPage++;
      final pagedResponse = await _service.fetchProcedures(
        profileType: pt,
        profileTypeId: id,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...pagedResponse.items],
        isLoading: false,
        hasNext: pagedResponse.hasNext,
        totalCount: pagedResponse.totalCount,
      );

      final pid = _ref.read(activeProfileProvider)?.id;
      if (pid != null && pid.isNotEmpty) {
        _mergeUserProcedures(pid);
      }
    } catch (e, st) {
      _currentPage--;
      state = state.copyWith(isLoading: false, error: e, stackTrace: st);
    }
  }

  Future<void> startProcedure(String procedureId) async {
    state = state.copyWith(
      loadingProcedureIds: {...state.loadingProcedureIds, procedureId},
    );

    final started = Set<String>.from(state.startedProcedureIds);
    if (started.contains(procedureId)) {
      _removeLoading(procedureId);
      return;
    }
    if (state.completedProcedureIds.contains(procedureId)) {
      _removeLoading(procedureId);
      return;
    }

    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) {
      _removeLoading(procedureId);
      return;
    }

    try {
      final userProcedureId = await _service.startProcedure(
        profileId: profileId,
        procedureId: procedureId,
      );
      started.add(procedureId);
      final mapping = Map<String, String>.from(state.userProcedureIds)
        ..[procedureId] = userProcedureId;
      state = state.copyWith(
        startedProcedureIds: started,
        userProcedureIds: mapping,
        loadingProcedureIds: {...state.loadingProcedureIds}..remove(procedureId),
      );
    } catch (_) {
      _removeLoading(procedureId);
    }
  }

  Future<void> completeProcedure(String procedureId, {List<String> uploadedDocumentIds = const []}) async {
    state = state.copyWith(
      loadingProcedureIds: {...state.loadingProcedureIds, procedureId},
    );

    final completed = Set<String>.from(state.completedProcedureIds);
    if (completed.contains(procedureId)) {
      _removeLoading(procedureId);
      return;
    }
    if (!state.startedProcedureIds.contains(procedureId)) {
      _removeLoading(procedureId);
      return;
    }

    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) {
      _removeLoading(procedureId);
      return;
    }

    try {
      final userProcedureId = state.userProcedureIds[procedureId];
      if (userProcedureId == null) {
        _removeLoading(procedureId);
        return;
      }
      await _service.completeProcedure(
        userProcedureId: userProcedureId,
        profileId: profileId,
        uploadedDocumentIds: uploadedDocumentIds,
      );
      completed.add(procedureId);
      state = state.copyWith(
        completedProcedureIds: completed,
        loadingProcedureIds: {...state.loadingProcedureIds}..remove(procedureId),
      );
    } catch (_) {
      _removeLoading(procedureId);
    }
  }

  void _removeLoading(String procedureId) {
    state = state.copyWith(
      loadingProcedureIds: {...state.loadingProcedureIds}..remove(procedureId),
    );
  }
}
