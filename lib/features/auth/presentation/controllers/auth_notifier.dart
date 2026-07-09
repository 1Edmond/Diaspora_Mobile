import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';
import '../../../../core/di/injection.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      return AuthNotifier(getIt<IAuthRepository>());
    });

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final IAuthRepository repository;
  AuthNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> register(String phone, String password, String userType) async {
    state = const AsyncValue.loading();
    try {
      await repository.register(phone, password, userType);
      state = const AsyncValue.data(null); // Or keep previous state if needed
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> verifyPhone(String phone, String otp) async {
    state = const AsyncValue.loading();
    try {
      final ok = await repository.verifyPhone(phone, otp);
      if (ok) {
        state = const AsyncValue.data(null);
      } else {
        // If verify fails but no exception, maybe set error or just return false
        state = const AsyncValue.data(null);
      }
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await repository.login(phone, password);
      // Assuming res['user'] is the JSON map for User
      final user = UserModel.fromJson(res['user']);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
  }
}
