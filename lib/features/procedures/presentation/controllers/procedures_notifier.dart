import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/procedure_model.dart';
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
}
