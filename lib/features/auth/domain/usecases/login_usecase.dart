import '../repositories/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;
  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
