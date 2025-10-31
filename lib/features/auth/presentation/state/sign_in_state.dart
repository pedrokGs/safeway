import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';

class SignInState extends Equatable{
  final String? errorMessage;
  final bool isLoading;
  final bool success;

  const SignInState({this.errorMessage, this.isLoading = false, this.success = false});

  @override
  List<Object?> get props => [errorMessage, isLoading, success];
}

class SignInStateNotifier extends Notifier<SignInState>{
  late final SignInWithEmailAndPasswordUseCase signInUseCase;
  late final SignInWithGoogleUseCase signInWithGoogleUseCase;

  @override
  SignInState build() {
    signInUseCase = ref.watch(signInWithEmailAndPasswordUseCaseProvider);
    signInWithGoogleUseCase = ref.watch(signInWithGoogleUseCaseProvider);
    return SignInState();
  }

  Future<void> signIn(String email, String password) async {
    state = SignInState(isLoading: true);
    try{
      await signInUseCase.call(email: email, password: password);
      state = SignInState(isLoading: false, success: true);
    } on InvalidCredentialsException {
      state = SignInState(isLoading: false, errorMessage: "Credenciais inválidas, verifique a senha e o email");
    } on UserNotFoundException {
      state = SignInState(isLoading: false, errorMessage: "Usuário não encontrado");
    } catch (e) {
      state = SignInState(isLoading: false, errorMessage: "Erro desconhecido: $e");
    }
  }

  Future<void> signInWithGoogle() async{
    state = SignInState(isLoading: true);
    try{
      await signInWithGoogleUseCase.call();
      state = SignInState(isLoading: false, success: true);
    } on InvalidCredentialsException{
      state = SignInState(isLoading: false, errorMessage: "Credenciais inválidas");
    } on GoogleSignInCancelledException{
      state = SignInState(isLoading: false, errorMessage: "A entrada foi cancelada");
    } catch(e){
      state = SignInState(isLoading: false, errorMessage: "Erro deconhecido: $e");
    }
  }
}