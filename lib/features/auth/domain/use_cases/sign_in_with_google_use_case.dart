import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase{
  final AuthRepository repository;

  SignInWithGoogleUseCase({required this.repository});

  Future<String> call() async{
    return await repository.signInWithGoogle();
  }
}