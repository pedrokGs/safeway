import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase{
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> call() async{
    return await repository.signOut();
  }
}