import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/procedure_service.dart';
import '../../data/models/procedure_model.dart';
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

  const ProceduresState({
    this.items = const [],
    this.isLoading = false,
    this.hasNext = false,
    this.totalCount = 0,
    this.error,
    this.stackTrace,
    this.startedProcedureIds = const {},
    this.completedProcedureIds = const {},
  });

  ProceduresState copyWith({
    List<ProcedureModel>? items,
    bool? isLoading,
    bool? hasNext,
    int? totalCount,
    Object? error,
    StackTrace? stackTrace,
    Set<String>? startedProcedureIds,
    Set<String>? completedProcedureIds,
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
      notifier.fetch();
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

  Future<void> fetch({int profileType = 0, String? profileTypeId}) async {
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
      state = ProceduresState(
        items: pagedResponse.items,
        isLoading: false,
        hasNext: pagedResponse.hasNext,
        totalCount: pagedResponse.totalCount,
      );
    } catch (e, st) {
      state = ProceduresState(error: e, stackTrace: st);
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
    } catch (e, st) {
      _currentPage--;
      state = state.copyWith(isLoading: false, error: e, stackTrace: st);
    }
  }

  Future<void> startProcedure(String procedureId) async {
    final started = Set<String>.from(state.startedProcedureIds);
    if (started.contains(procedureId)) return;
    if (state.completedProcedureIds.contains(procedureId)) return;

    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) return;

    try {
      await _service.startProcedure(profileId: profileId, procedureId: procedureId);
      started.add(procedureId);
      state = state.copyWith(startedProcedureIds: started);
    } catch (_) {}
  }

  Future<void> completeProcedure(String procedureId) async {
    final completed = Set<String>.from(state.completedProcedureIds);
    if (completed.contains(procedureId)) return;
    if (!state.startedProcedureIds.contains(procedureId)) return;

    final profile = _ref.read(activeProfileProvider);
    final profileId = profile?.id;
    if (profileId == null || profileId.isEmpty) return;

    final isInternal = profile?.isInternal ?? true;

    try {
      await _service.completeProcedure(
        procedureId: procedureId,
        profileId: profileId,
        isInternal: isInternal,
      );
      completed.add(procedureId);
      state = state.copyWith(completedProcedureIds: completed);
    } catch (_) {}
  }
}
