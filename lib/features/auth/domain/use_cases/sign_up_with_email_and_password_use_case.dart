import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

import '../exceptions/invalid_credentials_exception.dart';

class SignUpWithEmailAndPasswordUseCase{
  final AuthRepository repository;

  SignUpWithEmailAndPasswordUseCase({required this.repository});

  Future<String> call({required String email, required String password}) async{
    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)){
      throw InvalidCredentialsException();
    }

    if(!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$').hasMatch(password)){
      throw InvalidCredentialsException();
    }

    return await repository.signUpWithEmailAndPassword(email: email, password: password);
  }
}