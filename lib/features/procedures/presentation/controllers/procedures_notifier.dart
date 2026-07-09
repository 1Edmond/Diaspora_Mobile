import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/procedure_model.dart';
import '../../data/models/step_model.dart';
import '../../../../core/network/mock_api.dart';

final proceduresProvider = StateNotifierProvider<ProceduresNotifier, AsyncValue<List<ProcedureModel>>>((ref) {
  return ProceduresNotifier();
});

class ProceduresNotifier extends StateNotifier<AsyncValue<List<ProcedureModel>>> {
  ProceduresNotifier() : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final data = await MockApi.procedures();
      final list = data.map((e) => ProcedureModel.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggleStep(String procedureId, String stepId) {
    state.whenData((items) {
      final updated = items.map((p) {
        if (p.id != procedureId) return p;
        final updatedSteps = p.steps.map((s) {
          if (s.id != stepId) return s;
          return s.copyWith(isCompleted: !s.isCompleted);
        }).toList();
        final completedCount = updatedSteps.where((s) => s.isCompleted).length;
        final progress = updatedSteps.isEmpty ? 0 : ((completedCount / updatedSteps.length) * 100).round();
        return p.copyWith(steps: updatedSteps, userProgress: progress);
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}
